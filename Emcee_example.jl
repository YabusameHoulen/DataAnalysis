using CairoMakie
using Turing
using Random
Random.seed!(123);

## Choose the "true" parameters.

const m_true = -0.9594
const b_true = 4.294
const f_true = 0.534

## Generate some synthetic data from the model.

N = 50
x = sort(10 * rand(N))
y = @. m_true * x + b_true
yerr = 0.1 .+ 0.5 * rand(N)
y += yerr .* randn(N)
y += abs.(f_true * y) .* randn(N)  ### 对误差建模(最小二乘法被低估的部分)

## show plot
begin
    x_0 = range(0, 10, length=50)
    fig, ax, _ = errorbars(x_0, y, yerr, whiskerwidth=3)
    scatter!(ax, x_0, y)
    lines!(ax, x_0, m_true .* x_0 .+ b_true, color=:red)
    fig
end

## linear least square
using LinearAlgebra
using Printf

function vander!(V::AbstractMatrix, x::AbstractVector, n=length(x))
    m = length(x)
    (m, n) == size(V) || throw(DimensionMismatch())
    for j = 1:m
        @inbounds V[j, 1] = one(x[j])
    end
    for i = 2:n, j = 1:m
        @inbounds V[j, i] = x[j] * V[j, i-1]
    end
    return V
end
vander(x::AbstractVector, n=length(x)) = vander!(Array{eltype(x)}(undef, length(x), n), x, n)

begin
    A = vander(x, 2)
    C = diagm(yerr .* yerr)
    b, m = inv(A' * inv(C) * A) * A' * inv(C) * y
    cov_linear = inv(A' * inv(C) * A)

    @printf "Least-squares estimates:\n"
    @printf "m = %.3f ± %.3f\n" m cov_linear[1, 1]
    @printf "b = %.3f ± %.3f" b cov_linear[2, 2]

    x_0 = range(0, 10, length=50)
    fig, ax, _ = errorbars(x_0, y, yerr, whiskerwidth=3)
    scatter!(ax, x_0, y)
    lines!(ax, x_0, m_true .* x_0 .+ b_true, color=:red, label="true line")
    lines!(ax, x_0, m .* x_0 .+ b, color=:blue, label="least square fit")
    axislegend()
    fig
end

## maximum likelihood estimation
using Optim
line_func(x, m, b) = m .* x .+ b
function log_likelihood(θ, x, y, yerr)
    m, b, log_f = θ
    ### 使用log_f而非f本身， 可以强迫f>0
    model = line_func(x, m, b)
    sigma2 = yerr .^ 2 .+ model .^ 2 .* exp(2 * log_f)
    return -0.5 * sum((y .- model) .^ 2 ./ sigma2 + log.(sigma2))
end

u0 = [-1.0, 4.0, -0.5]
sol = optimize(θ -> -log_likelihood(θ, x, y, yerr), u0)
m_ml, b_ml = Optim.minimizer(sol)

begin
    x_0 = range(0, 10, length=50)
    fig, ax, _ = errorbars(x_0, y, yerr, whiskerwidth=3)
    scatter!(ax, x_0, y)
    lines!(ax, x_0, line_func(x_0, m_true, b_true), color=:red, label="true line")
    lines!(ax, x_0, line_func(x_0, m, b), color=:blue, label="least square fit")
    lines!(ax, x_0, line_func(x_0, m_ml, b_ml), color=:green, label="maximum likelihood")
    axislegend()
    fig

end

## bayesian
using Turing
using LinearAlgebra
@model function linear_fitting(x, y, yerr)
    m_prior ~ Uniform(-5, 0.5)
    b_prior ~ Uniform(0, 10)
    f_prior ~ Uniform(-10, 1)
    σ₂ = f_prior^2 .* (line_func(x, m_prior, b_prior)) .^ 2 .+ yerr .^ 2
    return y ~ MvNormal(line_func(x, m_prior, b_prior), diagm(σ₂))
end

model = linear_fitting(x, y, yerr)

model.args
model.context
model.defaults
model.f

chain = sample(model, NUTS(0.65), 3_000)

@vsshow chain
@vsshow summarize(chain)

mean(chain[:acceptance_rate])

using AlgebraOfGraphics
using PairPlots

params = names(chain, :parameters)


margin_p = mapping(params .=> "sample value") *
           mapping(;
    row=dims(1) => renamer(params)
)


begin
    chain_mapping =
        mapping(params .=> "sample value") *
        mapping(;
            # color=:chain => nonnumeric,
            row=dims(1) => renamer(params)
        )
    plt = data(chain) * mapping(:iteration) * chain_mapping * visual(Lines)
    draw(plt)
end

pairplot(chain)


begin
    x_0 = range(0, 10, length=50)
    fig, ax, _ = errorbars(x_0, y, yerr, whiskerwidth=3)
    scatter!(ax, x_0, y)
    lines!(ax, x_0, line_func(x_0, m_true, b_true), color=:red, label="true line")
    lines!(ax, x_0, line_func(x_0, m, b), color=:blue, label="least square fit")
    lines!(ax, x_0, line_func(x_0, m_ml, b_ml), color=:green, label="maximum likelihood")
    for (m_post, b_post) in zip(chain[:m_prior], chain[:b_prior])
        lines!(ax, x_0, line_func(x_0, m_post, b_post),
            alpha=0.01,
            color=:gray,
            label="bayes regression"
        )
    end
    axislegend(; merge=true, unique=true)
    fig
end

using StatsBase
chain
StatsBase.percentile(vec(chain[:f_prior].data), 16)
StatsBase.percentile(vec(chain[:f_prior].data), 50)
StatsBase.percentile(vec(chain[:f_prior].data), 84)

begin
    x_0 = range(0, 10, length=50)
    fig, ax, _ = errorbars(x_0, y, yerr, whiskerwidth=3)
    scatter!(ax, x_0, y)
    lines!(ax, x_0, line_func(x_0, m_true, b_true), color=:red, label="true line")
    lines!(ax, x_0, line_func(x_0, m, b), color=:blue, label="least square fit")
    lines!(ax, x_0, line_func(x_0, m_ml, b_ml), color=:green, label="maximum likelihood")
    for (m_post, b_post) in zip(chain[:m_prior], chain[:b_prior])
        if (m_post < percentile(vec(chain[:m_prior].data), 84)
            &&
            m_post > percentile(vec(chain[:m_prior].data), 16)) &&
           (b_post < percentile(vec(chain[:b_prior].data), 84)
            &&
            b_post > percentile(vec(chain[:b_prior].data), 16))
            lines!(ax, x_0, line_func(x_0, m_post, b_post),
                alpha=0.008,
                color=:purple,
                label="bayes regression"
            )
        end
        lines!(ax, x_0, line_func(x_0, m_post, b_post),
            alpha=0.01,
            color=:gray,
            label="bayes regression"
        )
    end
    axislegend(; merge=true, unique=true)
    fig
end


predict(linear_fitting([1, 2, 3], missing, [1, 1, 1]), chain)