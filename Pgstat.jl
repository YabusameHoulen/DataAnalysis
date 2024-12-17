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

