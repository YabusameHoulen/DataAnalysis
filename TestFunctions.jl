## potential Pgstat
using Turing
using Random

# Generate synthetic data
Random.seed!(123)
true_signal = 5.0
true_mu_b = 10.0
true_sigma_b = 2.0
n_obs = 100

# Simulate background from Gaussian
background = rand(Normal(true_mu_b, true_sigma_b), n_obs)

# Simulate Poisson counts based on signal + background
observed_counts = [rand(Poisson(true_signal + b)) for b in background]

# Turing model definition
@model function poisson_gaussian_model(observed_counts)
    # Priors for signal and background parameters
    s ~ Exponential(1.0)        # Signal (positive prior)
    μ_b ~ truncated(Normal(0, 10), 0, Inf)         # Background mean
    σ_b ~ truncated(Normal(0, 5), 0, Inf) # Background std (non-negative)
    b ~ Normal(μ_b, σ_b)
    # Background modeled as Gaussian
    for i in 1:length(observed_counts)
        # Background
        λ = s + b               # Poisson mean
        observed_counts[i] ~ Poisson(λ)
    end
end

# Instantiate the model
model = poisson_gaussian_model(observed_counts)

# Perform sampling with MCMC
chain = sample(model, NUTS(), 1000)

# Analyze the results
using CairoMakie
using AlgebraOfGraphics

## a suit implement with namedtuples
const Ranks = [string.(2:10); ["J", "Q", "K", "A"]]
const Suits = split("♠ ♢ ♣ ♡")
Card = NamedTuple{(:rank, :suit)}
"This is a big Cards"
@kwdef struct Cards{Card} <: AbstractVector{Card}
    cards::Vector{Card} = [Card((rank, suit)) for rank in Ranks for suit in Suits]
end
### 当 announce as the subtype of AbstractVector 后只用指定两种接口。。。
Base.size(a::Cards) = size(a.cards)
Base.getindex(a::Cards, ind) = a.cards[ind]

Iterators.reverse(a)

a = Cards()
length(a)
a[begin:5:end]
rand(a, 15)
Card(("Q", "♡")) in a

indexin(Ranks, "3")
"3" in Ranks


spading(a::Card) = 4 * findfirst(==(a.rank), Ranks) + 4 - findfirst(==(a.suit), Suits)
sort(a, by=spading)

for card in a
    @show card
end
for card in Iterators.reverse(a)
    @show card
end

## 如果不为AbstractArray的subtype
@kwdef struct MyCards
    cards::Vector{Card} = [Card((rank, suit)) for rank in Ranks for suit in Suits]
end

Base.firstindex(a::MyCards) = 1
Base.lastindex(a::MyCards) = length(a)
Base.getindex(a::MyCards, ind) = a.cards[ind]
Base.keys(a::MyCards) = 1:length(a)

Base.length(a::MyCards) = length(a.cards)
Base.iterate(a::MyCards, state=1) = state > length(a) ? nothing : (a[state], state + 1)
Base.rand(a::MyCards, d::Integer) = rand(a.MyCards, d)

b = MyCards()
for card in b
    @show card
end
for card in Iterators.reverse(b)
    @show card
end

## julia's broadcast
stack(Ranks[end-3:end]) .* Suits

stack(rpad.(["Rust", "Julia", "Python"], 6), dims=1)

stack(Ref.(["Rust", "Julia", "Python"]))
hcat(["Rust", "Julia", "Python"]...)
reduce(hcat, ["Rust", "Julia", "Python"])

stack((1:4, 10:13))
stack(zip(1:4, 10:13))
hcat(1:4, 10:13)
reshape(["Rust", "Julia", "Python"], (1, 3))

a = [[1, 2], [3, 4], [5, 6]]
stack(a)
stack(a, dims=1)
reduce(vcat, a')

colors = ["black", "white"]
sizes = [:S, :M, :L]
tshirts = [(color, size) for color in colors for size in sizes]

for color in colors, size in sizes
    @show (color, size)
end

for color in colors
    for size in sizes
        @show (color, size)
    end
end

for size in sizes, color in colors
    @show (color, size)
end

## Julia Generator
gen = (sin(x) for x in 1:5)