using Distributions
using StatsPlots
using AdvancedMH
using MCMCChains
using LinearAlgebra

data = rand(Normal(0, 1), 30);

# Define a basic model.
insupport(θ) = θ[2] >= 0
dist(θ) = Normal(θ[1], θ[2])
function density(θ)
    # Define a prior for the mean and variance
    mu_prior = Normal(-1, 2)
    sigma_prior = InverseGamma(2, 3)
    
    # Calculate likelihood + prior
    if insupport(θ)
        return sum(logpdf.(dist(θ), data)) + 
            logpdf(mu_prior, θ[1]) + 
            logpdf(sigma_prior, θ[2])
    else
        # If it's out of the support, the probability
        # of this parameterization is 0 => log(0) = -Inf
        return -Inf
    end
end;


# Construct a DensityModel, a wrapper struct that goes around a function.
model = DensityModel(density)

# Set up our sampler with a joint multivariate Normal proposal.
spl = RWMH(MvNormal(zeros(2), I));



# Sample from the posterior.
chain = sample(
    model, 
    spl, 
    1000; # Number of samples to draw (1000 is really small for MH -- real runs should be much higher)
    param_names=["μ", "σ"], 
    chain_type=Chains       # To 
);

# Display summary statistics
display(chain)

# Extract mean values and plot them
μ = chain["μ"]
plot(μ, label="μ", xlabel="Iteration number", ylabel="Value")
histogram(μ, label="μ", xlabel="Value", ylabel="Count")

# Sample from the posterior.
chain = sample(
    model, 
    spl, 
    1_000_000;
    param_names=["μ", "σ"], 
    chain_type=Chains       # To 
);

display(chain)

μ = chain["μ"]

plot(chain)

histogram(chain)

@edit 4+5