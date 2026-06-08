---
title: "Fast Stable Restricted Maximum Likelihood and Marginal Likelihood Estimation of Semiparametric Generalized Linear Models"
type: source
tags: [method, mgcv, gam, smoothing, REML]
date: 2011-01-01
source_file: knowledge/raw/papers/wood-2011-gam-reml.md
---

## Summary
Wood develops the first computationally stable, full-Newton method for *direct* GAM smoothness selection. Previous schemes (Performance Oriented Iteration, PQL) iteratively re-select smoothing parameters on working linear models and routinely fail to converge — especially with binary data or concurvity. The new method optimizes the whole-model criterion (REML, ML, GCV, or generalized AIC) with exact first and second derivatives. Implemented in `mgcv` as `method = "REML"`.

## Canonical API
```R
library(mgcv)

fit <- gam(
  formula = CLM_AMT ~ s(AGE, k = 10) + s(BLUEBOOK, k = 10) +
                      s(INCOME, k = 10) + s(MVR_PTS, k = 5) +
                      AREA,                       # factors enter directly
  data    = train,
  family  = Tweedie(p = 1.5, link = "log"),       # NOTE: capital-T Tweedie, mgcv's family
  method  = "REML",                                # use REML, not GCV.Cp
  select  = TRUE                                   # variable selection via shrinkage
)

y_hat <- predict(fit, newdata = test, type = "response")
summary(fit)         # smooth-term significance via approximate p-values
plot(fit, pages = 1) # smooth function visualizations
```

End-to-end: `[[examples/wood-2011-gam-reml]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended | Sensible grid |
|---|---|---|---|---|
| `method` | smoothness selection criterion | `"GCV.Cp"` (legacy) | **`"REML"`** for stability | `"REML"`, `"ML"`, `"GCV.Cp"` |
| `k` (per smooth) | basis dimension | 10 | start at 10; check via `gam.check` | 5, 10, 20 |
| `bs` (per smooth) | spline basis type | `"tp"` (thin plate) | `"tp"` or `"cr"` (cubic regression) | `"tp"`, `"cr"`, `"cs"` |
| `p` (Tweedie family) | variance power | 1.5 | estimate via `family = tw()` (estimates p automatically) | use `tw()` if uncertain |
| `select` | variable selection via shrinkage | FALSE | TRUE for many smooth terms | TRUE |
| `gamma` (penalty multiplier) | overfitting guard | 1 | 1.4 to bias toward smoother fits | {1, 1.4} |

## Argument Quirks
- **`Tweedie(p, link)` (capital T) is `mgcv`'s family** and requires a fixed `p`. **`tw()` (lowercase)** estimates `p` from the data — usually what you want.
- `s(x, k = 10)` — `k` is the *maximum* basis dimension; the effective DF is shrunk by REML toward an interior optimum. After fitting, run `gam.check(fit)` — if k-index ≪ 1, raise `k`.
- Factors **do not go inside `s(...)`** — they enter the formula directly. `s(AREA, by = MARITAL)` is a *varying-coefficient* construct, not a way to smooth a categorical.
- `method = "GCV.Cp"` is the *legacy* default. Paper's whole point: this can silently fail. Always pass `method = "REML"` (or `"ML"`).
- `predict.gam(..., type = "response")` returns mean-scale predictions; `"link"` returns the linear predictor.

## Failure Modes
- **Convergence cycle** (P-IRLS oscillates) — historically common with binary data; the REML/full-Newton method addresses this directly. If it still cycles, increase `gam.control(maxit = 200)`.
- **`k` too small** — model underfits, smooths are stuck at low DF. Run `gam.check(fit)` and look at `k-index`.
- **Concurvity** — when smooth terms are nearly collinear functions of other smooth terms. Detect with `concurvity(fit)`; remedy by dropping or combining terms.
- For Tweedie, `family = tw()` can be sensitive to extreme zeros — large datasets with >95% zeros may need increased `epsilon` in `gam.control`.

## Code Example
See `[[examples/wood-2011-gam-reml]]`.

## Domain Pitfalls
- GAM with `tw()` is the closest drop-in to "Tweedie GLM with nonlinear effects." Often beats both the linear GLM and tree-boosted Tweedie when n is moderate and signal is smooth.
- The benchmark `archive/auto-insurance-bench-*/procedures/02_tweedie_gam.R` uses `method = "REML"` (good) but hardcodes `p = 1.7` instead of using `tw()` (room to improve).
- `s(longitude, latitude)` (tensor smooth) is the natural way to encode geographic factors that would otherwise be dummy-coded ZIP/region.

## Connections
- [[GeneralizedAdditiveModels]] — model class
- [[REML]] — estimation criterion
- [[PenalizedRegressionSplines]] — smooth representation
- [[Concurvity]] — diagnostic
- [[SimonNWood]]

## Contradictions
None with existing wiki content.
