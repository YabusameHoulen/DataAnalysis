using Distributions
using CairoMakie


### final plot
let
    f = Figure(;
        backgroundcolor=RGBf(0.98, 0.98, 0.98),
        size=(1000, 700))

    ax11, _ = lines(f[1, 1], Exponential(0.5);
        label=L"λ = 0.5", linewidth=5,
        axis=(; ylabel="Exponential pdf", limits=(0, 5, nothing, nothing)),
    )
    lines!(ax11, Exponential(1); label=L"λ = 1,0", linewidth=5)
    lines!(ax11, Exponential(1.5); label=L"λ = 1.5", linewidth=5)
    axislegend(ax11; position=(0.6, 0.3))

    ax12, _ = lines(f[1, 2], 0 .. 5, x -> cdf(Exponential(0.5), x),
        label=L"λ = 0.5", linewidth=5,
        axis=(; ylabel="Exponential cdf", limits=(0, 5, nothing, nothing)),
    )
    lines!(ax12, 0 .. 5, x -> cdf(Exponential(1), x); label=L"λ = 1,0", linewidth=5)
    lines!(ax12, 0 .. 5, x -> cdf(Exponential(1.5), x); label=L"λ = 1.5", linewidth=5)
    axislegend(ax12; position=(0.6, 0.7))

    ax21, _ = lines(f[2, 1], Normal(0, 0.2);
        label=L"μ = 0, σ² = 0.2", linewidth=5,
        axis=(; ylabel="normal pdf", limits=(-5, 5, nothing, nothing)),
    )
    lines!(ax21, Normal(0, 1); label=L"μ = 0,  σ² = 1", linewidth=3, linestyle=:dot)
    lines!(ax21, Normal(0, 5); label=L"μ = 0,  σ² = 5", linewidth=5, linestyle=:dash)
    lines!(ax21, Normal(-2, 0.5); label=L"μ = -2,  σ² = 0.5", linewidth=5, linestyle=:dashdot)
    axislegend(ax21; position=(0.9, 0.9))

    ax22, _ = lines(f[2, 2], -5 .. 5, x -> cdf(Normal(0, 0.2), x);
        label=L"μ = 0, σ² = 0.2", linewidth=5,
        axis=(; ylabel="normal pdf", limits=(-5, 5, nothing, nothing)),
    )
    lines!(ax22, -5 .. 5, x -> cdf(Normal(0, 1), x); label=L"μ = 0,  σ² = 1", linewidth=3, linestyle=:dot)
    lines!(ax22, -5 .. 5, x -> cdf(Normal(0, 5), x); label=L"μ = 0,  σ² = 5", linewidth=5, linestyle=:dash)
    lines!(ax22, -5 .. 5, x -> cdf(Normal(-2, 0.5), x); label=L"μ = -2,  σ² = 0.5", linewidth=5, linestyle=:dashdot)
    axislegend(ax22; position=(0.9, 0.2))

    ax31, _ = lines(f[3, 1], LogNormal(5);
        label=L"σ = 5", linewidth=5,
        axis=(; ylabel="LogNormal pdf", limits=(-0.2, 5, nothing, nothing)),
    )
    lines!(ax31, LogNormal(1); label=L"σ = 1", linewidth=3, linestyle=:dot)
    lines!(ax31, LogNormal(1 // 2); label=L"σ = 1/2", linewidth=5, linestyle=:dash)
    lines!(ax31, LogNormal(1 // 8); label=L"σ = 1/8", linewidth=5, linestyle=:dashdot)
    axislegend(ax31; position=(0.9, 0.9))

    ax32, _ = lines(f[3, 2], -0.2 .. 5, x -> cdf(LogNormal(5), x);
        label=L"σ = 5", linewidth=5,
        axis=(; ylabel="LogNormal pdf", limits=(-0.2, 3, nothing, nothing)),
    )
    lines!(ax32, -0.2 .. 5, x -> cdf(LogNormal(1), x); label=L"σ = 1", linewidth=3, linestyle=:dot)
    lines!(ax32, -0.2 .. 5, x -> cdf(LogNormal(1 // 2), x); label=L"σ = 1/2", linewidth=5, linestyle=:dash)
    lines!(ax32, -0.2 .. 5, x -> cdf(LogNormal(1 // 8), x); label=L"σ = 1/8", linewidth=5, linestyle=:dashdot)
    axislegend(ax32; position=(0.9, 0.1))
    f
end


save("chapter2_densityplots.svg",ans)