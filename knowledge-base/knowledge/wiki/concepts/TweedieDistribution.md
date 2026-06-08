---
title: "Tweedie Distribution"
type: concept
tags: [method, distribution]
sources: [smyth-jorgensen-2002-tweedie-dispersion, dunn-smyth-2008-tweedie-fourier, qian-2016-hdtweedie, yang-2016-tdboost, zhang-2013-cplm, delong-lindholm-wuthrich-2021-tweedie]
last_updated: 2026-05-31
---

## Definition
The Tweedie family is the subset of exponential dispersion models with power mean–variance relationship `Var(Y) = φ · μ^p`. For `1 < p < 2`, the distribution is a compound Poisson–gamma: a point mass at zero (probability `exp(-μ^(2-p)/(φ(2-p)))`) combined with a continuous gamma-like density on the positive reals. This makes it the canonical distribution for insurance claim amounts: most policies have zero claims, the rest have right-skewed positive losses.

## When to Use
- Modeling a non-negative continuous outcome with exact zeros (claim amounts, rainfall, biomass, expense)
- When zero-inflation is a *feature of the data-generating process*, not measurement censoring
- When fitting separate frequency + severity models is overkill or impossible (e.g., only aggregate total is recorded — see [[smyth-jorgensen-2002-tweedie-dispersion]])

## When NOT to Use
- When claim counts AND individual claim sizes are both available — fitting Poisson + Gamma separately is usually more interpretable and more robust ([[delong-lindholm-wuthrich-2021-tweedie]]); also see [[FrequencySeverityDecomposition]]
- For neural-network regression — Tweedie loss is hard to optimize near `p` boundaries; Poisson + gamma networks are more stable
- For `p` outside (1, 2) you're at a boundary case (Poisson, gamma, inverse Gaussian, normal) — use that distribution directly

## Canonical Call
```R
library(statmod)        # for use as a GLM family
glm(y ~ ., data = train,
    family = tweedie(var.power = 1.5, link.power = 0))   # link.power=0 means log

library(tweedie)        # for density evaluation
dtweedie(y, mu = 1, phi = 1, power = 1.5)
```
Verified end-to-end: `[[examples/smyth-jorgensen-2002-tweedie-dispersion]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended |
|---|---|---|---|
| `p` (var.power) | shape of mean-variance | 1.5 | **estimate from data** via `tweedie.profile` — do not hardcode |
| `phi` | dispersion | estimated | estimated; for DGLM, modeled as a function of covariates |
| `link.power` | link function | 0 (log) | 0 |

## Common Pitfalls
- **Hardcoding `p = 1.5` or `p = 1.7`.** Standard industry shortcut, but `p` has material impact on standard errors and Gini SEs. See [[TweedieVariancePowerEstimation]].
- **Filtering zero-claim rows.** Tweedie absorbs zeros — filtering destroys the signal it exists to model. The mean-variance relationship is calibrated on the *full* distribution including zeros.
- **Density near `p = 1` or `p = 2`** is numerically unstable. Either method (series or Fourier inversion — see [[dunn-smyth-2008-tweedie-fourier]]) struggles at the boundaries. Stay in (1.05, 1.95).
- **`var.power` vs `power` vs `alpha`** — argument name varies by package (`statmod` uses `var.power`, `tweedie` uses `power`, `TDboost` uses `alpha` in a distribution list). Same parameter, three names.
- **A Tweedie GLM can silently fail to converge.** The compound-Poisson response (a spike of exact zeros plus a long right tail) makes `glm()`'s IRLS prone to stopping *before* convergence under its default iteration cap and starting point, returning `NA`/`Inf` coefficients and worse-than-random predictions. Raising the IRLS iteration budget **and** supplying an explicit starting value both help; the exact settings vary by dataset, so tune them rather than copying a fixed recipe. Check `fit$converged` on every fit. See the convergence pitfall in [[GeneralizedLinearModels]].

## Sources
- [[smyth-jorgensen-2002-tweedie-dispersion]] — defining application to insurance claims with dispersion modeling
- [[dunn-smyth-2008-tweedie-fourier]] — numerical density evaluation
- [[qian-2016-hdtweedie]] — high-dim regularized estimation
- [[yang-2016-tdboost]] — boosted nonparametric fitting
- [[zhang-2013-cplm]] — mixed-model and Bayesian extensions
- [[delong-lindholm-wuthrich-2021-tweedie]] — comparison with Poisson-Gamma parametrization
