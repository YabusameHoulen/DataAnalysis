using SpecialFunctions: logfactorial

"fix the fact that for a machine 0 * log(inf) is nan, instead of 0"
@inline _xlogy(x, y) = x > 0 ? x * log(y) : zero(x)

"""
    poisson_observed_gaussian_background(obs_cnts, bkg_cnts, bkg_error, E_model_cnts)

A profile likelihood consider Poisson Data and Gaussian Background
"""
function poisson_observed_gaussian_background(obs_cnts, bkg_cnts, bkg_error, E_model_cnts)
    log_likes = similar(bkg_cnts, Float64)
    fs = similar(bkg_cnts, Float64)

    @fastmath for i in eachindex(log_likes)
        MB = E_model_cnts[i] + bkg_cnts[i]
        σ² = bkg_error[i] * bkg_error[i]
        fs[i] = 0.5 * (
            sqrt(MB * MB - 2 * σ² * (MB - 2 * obs_cnts[i]) + σ²^2) +
            bkg_cnts[i] - E_model_cnts[i] - σ²
        )
        # Now there are two branches:
        # when the background is not zero we use the profile likelihood
        # while when the background is 0
        # we are in the normal situation of a pure Poisson likelihood
        if bkg_cnts[i] > 0
            # bkgErr can be 0 only when also bkgCounts = 0
            # when bkgCounts = 0 and bkgErr=0 also f_i=0
            if obs_cnts[i] > 0
                log_likes[i] = obs_cnts[i] * log(fs[i] + E_model_cnts[i]) -
                               ((fs[i] - bkg_cnts[i])^2) / (2 * σ²) -
                               fs[i] - E_model_cnts[i] -
                               # Stirling's approximation using the Central Limit Theorem and the Poisson distribution
                               logfactorial(obs_cnts[i]) - 0.5 * log(2pi) - log(bkg_error[i])
            else
                log_likes[i] = -((fs[i] - bkg_cnts[i])^2) / (2 * σ²) -
                               fs[i] - E_model_cnts[i] -
                               0.5 * log(2pi) - log(bkg_error[i])
            end
        else
            log_likes[i] = _xlogy(obs_cnts[i], E_model_cnts[i]) -
                           E_model_cnts[i] -
                           logfactorial(obs_cnts[i])
        end
    end
    return log_likes, fs
end
