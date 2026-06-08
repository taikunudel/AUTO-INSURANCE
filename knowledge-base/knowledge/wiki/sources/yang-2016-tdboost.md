---
title: "Insurance Premium Prediction via Gradient Tree-Boosted Tweedie Compound Poisson Models"
type: source
tags: [method, TDboost, tweedie, boosting, insurance]
date: 2016-04-22
source_file: knowledge/raw/papers/yang-2016-tdboost.md
---

## Summary
Yang, Qian, and Zou replace the linear log-mean structure of the Tweedie GLM with a flexible boosted-tree ensemble. The TDboost algorithm is forward-stagewise gradient boosting under the Tweedie negative log-likelihood. ρ (variance power) and φ (dispersion) are estimated by profile likelihood. The R package `TDboost` includes partial-dependence plots so the model is not a complete black box.

## Canonical API
```R
library(TDboost)

# Profile-likelihood for rho (variance power) is INSIDE the package as
# TDboost(distribution=list(name="EDM", alpha=rho), ...) — alpha here means rho
fit <- TDboost(
  formula      = CLM_AMT ~ AGE + BLUEBOOK + MVR_PTS + AREA + ...,
  data         = train,
  distribution = list(name = "EDM", alpha = 1.5),   # alpha IS the variance power
  n.trees      = 3000,
  interaction.depth = 3,
  shrinkage    = 0.005,                              # paper-recommended
  bag.fraction = 0.5,
  cv.folds     = 5,
  keep.data    = FALSE
)

# Pick best iteration from CV
best_iter <- TDboost.perf(fit, method = "cv", plot.it = FALSE)
y_hat     <- predict(fit, newdata = test, n.trees = best_iter, type = "response")

# Interpretation
relative.influence(fit, n.trees = best_iter)         # variable importance
plot(fit, i.var = "AGE", n.trees = best_iter)        # partial dependence
```

End-to-end: `[[examples/yang-2016-tdboost]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended | Sensible grid |
|---|---|---|---|---|
| `distribution$alpha` | variance power ρ, in (1, 2) | 1.5 | profile via inner loop | {1.3, 1.5, 1.7} |
| `n.trees` | boosting rounds | 100 | 3000+ with `shrinkage = 0.005`; pick via `TDboost.perf` | 1000–5000 |
| `shrinkage` (ν) | learning rate | 0.001 | **0.005** (paper) | 0.001, 0.005, 0.01 |
| `interaction.depth` (L) | tree depth | 1 | 3–5 for interactions | {1, 3, 5} |
| `bag.fraction` | row subsample per tree | 0.5 | 0.5 | 0.5, 0.7 |
| `cv.folds` | CV for picking `n.trees` | 0 (off) | 5 | 5, 10 |

## Argument Quirks
- The argument is **`distribution = list(name = "EDM", alpha = ρ)`** — `alpha` here is the *variance power*, NOT the elastic net mixing or a learning rate. Confusingly overloaded name; the benchmark scripts in `archive/auto-insurance-bench-*` get this right.
- `n.trees` is the *maximum* number of trees fit; the optimal number must be selected via `TDboost.perf(..., method = "cv")`. Predicting with the full `n.trees` overfits.
- `keep.data = FALSE` matters for memory if the dataset is wide. Setting `TRUE` (the default) caches the training data inside the fit object.
- Exposure: TDboost does **not** support a `weights` or `offset` argument that maps cleanly to Tweedie exposure. The conventional workaround is modeling `CLM_AMT / exposure` and weighting by `exposure`, but the weighting must be passed as `w` — check vignette before relying.

## Failure Modes
- **Overfitting with too many trees.** Always use `TDboost.perf(..., method = "cv")` to select `best_iter`. Predicting at `n.trees = fit$n.trees` (no selection) is a common mistake.
- Convergence stalls for very sparse zero-inflated data (>98% zeros) — increase `bag.fraction` to 0.7 or use stratified sampling.
- Categorical variables with many rare levels cause unstable splits — bucket levels with <1% frequency before fitting.
- `predict` with `type = "response"` requires a fitted distribution; if `keep.data = FALSE` AND the original data frame is no longer available, you must recreate the distribution object.

## Code Example
See `[[examples/yang-2016-tdboost]]`.

## Domain Pitfalls
- Partial-dependence plots for actuarial pricing should be checked for monotonicity violations (e.g., young drivers being cheaper than middle-aged). The paper notes "risk does not monotonically decrease as age increases" — fine for prediction, but final rates often need monotone post-processing.
- Boosting absorbs zero-inflation naturally via the EDM distribution. Do NOT filter zero-claim rows.
- TDboost is nonparametric — no built-in handling for unseen factor levels in test. Predictions for new levels fall back to the marginal mean.

## Connections
- [[GradientTreeBoosting]] — core algorithm
- [[TweedieDistribution]] — response distribution
- [[ProfileLikelihood]] — for ρ, φ
- [[PartialDependencePlots]] — interpretation
- [[YiYang]], [[WeiQian]], [[HuiZou]]

## Contradictions
None with existing wiki content.
