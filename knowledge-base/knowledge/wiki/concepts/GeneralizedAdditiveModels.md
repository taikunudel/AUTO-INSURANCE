---
title: "Generalized Additive Models (GAMs)"
type: concept
tags: [method, mgcv]
sources: [wood-2011-gam-reml]
last_updated: 2026-05-31
---

## Definition
GAMs extend GLMs by allowing some linear terms to be replaced with smooth functions of covariates: `g(μ_i) = β_0 + Σ_j f_j(x_ij)`. Smooths `f_j` are represented as penalized regression splines; smoothness is selected automatically via REML, GCV, or related criteria. Implemented in R as `mgcv` ([[SimonNWood]]). The 2011 paper introduces the first stable full-Newton method for direct whole-model smoothness selection.

## When to Use
- When the relationship between a continuous predictor and the response is plausibly nonlinear (age, vehicle value, geography)
- Drop-in successor to GLM when you suspect non-monotonic or non-log-linear effects
- For spatial smoothing — `s(longitude, latitude)` tensor smooths beat ZIP-code dummy coding
- For interpretable nonlinearity — partial-effect plots are the natural output

## When NOT to Use
- When interactions among many predictors dominate — boosting wins (see [[GradientTreeBoosting]])
- When most predictors are categorical — GAM degenerates to GLM
- For very large n with very high-dimensional categorical predictors — `mgcv::bam` is the scalable alternative

## Canonical Call
```R
library(mgcv)

fit <- gam(
  CLM_AMT ~ s(AGE, k = 10) + s(BLUEBOOK, k = 10) + s(INCOME, k = 10) + AREA,
  data    = train,
  family  = tw(),                                 # tw() estimates Tweedie p
  method  = "REML",                                # never GCV.Cp — see paper
  select  = TRUE                                   # variable selection via shrinkage
)

y_hat <- predict(fit, newdata = test, type = "response")
gam.check(fit)                                     # diagnostic — k-index, residuals
plot(fit, pages = 1)                               # smooth-function plots
```
See `[[examples/wood-2011-gam-reml]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended |
|---|---|---|---|
| `method` | smoothness selection | `"GCV.Cp"` | **`"REML"`** for stability |
| `k` (per smooth) | basis dimension | 10 | start at 10; raise if `gam.check` k-index < 1 |
| `bs` (per smooth) | basis type | `"tp"` thin-plate | `"tp"` or `"cr"`; `"cs"` for shrinkage-enabled |
| `select` | shrinkage for variable selection | FALSE | TRUE if you want effective variable selection |
| `family` | distribution + link | gaussian | `tw()` (Tweedie, p estimated) for claims |
| `gamma` (penalty multiplier) | smoothness bias | 1 | 1.4 to encourage smoother fits |

## Common Pitfalls
- **`method = "GCV.Cp"` (the legacy default) can silently fail to converge** — the paper exists specifically because of this. Always pass `method = "REML"`.
- **Factors inside `s(...)`** — `s(AREA)` errors; factors enter directly as `+ AREA` or via `s(continuous, by = factor)` for varying-coefficient
- **`k` too small** — smooth is stuck near low DF. Diagnose via `gam.check(fit)`; raise `k` if needed
- **`k` too *large* for the data — a hard crash, not a warning.** `mgcv` errors with *"A term has fewer unique covariate combinations than specified maximum degrees of freedom"* when a smooth's `k` exceeds the number of **unique values** of that covariate. This is data-driven: a discrete or near-constant column can crash even at the default `k = 10`. Cap each smooth at `k = min(desired_k, n_unique - 1)`, and fall back to a plain linear term `+ col` when a column has only a handful of distinct values. Decide this **from the actual data** (count unique values per column) — never hardcode one `k` across datasets.
- **`Tweedie(p)` (capital T) vs `tw()` (lowercase)** — first requires fixed `p`, second estimates it. For most claim work, use `tw()`
- **Concurvity** (smooth analog of collinearity) — `concurvity(fit)` will surface; reduce by dropping or combining smooths

## Sources
- [[wood-2011-gam-reml]] — defines the direct full-Newton smoothness selection method used in modern `mgcv`
