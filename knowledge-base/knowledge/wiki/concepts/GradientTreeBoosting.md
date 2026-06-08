---
title: "Gradient Tree-Boosting (for Tweedie)"
type: concept
tags: [method, TDboost, boosting]
sources: [yang-2016-tdboost]
last_updated: 2026-05-15
---

## Definition
A forward-stagewise ensemble method: each iteration fits a small regression tree to the negative gradient of the loss with respect to the current prediction, then adds it (scaled by a shrinkage factor) to the running estimate. For Tweedie pricing, the loss is the Tweedie negative log-likelihood (Yang–Qian–Zou 2016; implemented as the `TDboost` R package). Captures nonlinearities and interactions without specifying them in advance.

## When to Use
- When you suspect substantial interactions among predictors (age × vehicle value, region × driver record) that linear or additive models miss
- When n is large enough (≥10k typical) to support nonparametric flexibility
- As a "benchmark" or upper-bound model — if a tuned GLM/GAM can match boosted accuracy, it's preferred for interpretability

## When NOT to Use
- When the dataset is small (a few thousand rows) and signal is weak — GAM or regularized GLM often wins
- When monotonicity is required (e.g., MVR points → premium must be monotone) — boosting needs explicit constraints or post-processing
- When regulator demands a fully interpretable rate structure — partial dependence is interpretable but not "transparent" in the GLM sense

## Canonical Call
```R
library(TDboost)

fit <- TDboost(
  formula      = CLM_AMT ~ AGE + BLUEBOOK + MVR_PTS + INCOME + AREA + ...,
  data         = train,
  distribution = list(name = "EDM", alpha = 1.5),    # alpha = variance power
  n.trees      = 3000,
  interaction.depth = 3,
  shrinkage    = 0.005,
  bag.fraction = 0.5,
  cv.folds     = 5
)

best_iter <- TDboost.perf(fit, method = "cv", plot.it = FALSE)
y_hat     <- predict(fit, newdata = test, n.trees = best_iter, type = "response")
```
See `[[examples/yang-2016-tdboost]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended |
|---|---|---|---|
| `distribution$alpha` | Tweedie variance power | 1.5 | profile from data |
| `n.trees` | max boosting rounds | 100 | 3000+ with shrinkage 0.005; pick via CV |
| `shrinkage` (ν) | learning rate | 0.001 | 0.005 |
| `interaction.depth` (L) | tree depth (1 = stumps) | 1 | 3–5 for meaningful interactions |
| `bag.fraction` | row subsample | 0.5 | 0.5 |
| `cv.folds` | CV for picking n.trees | 0 (off) | 5 |

## Common Pitfalls
- **Predicting at `n.trees = fit$n.trees`** instead of the CV-selected best_iter — overfits silently; predictions look fine but generalize poorly
- **`distribution$alpha` overloaded name** — it's the Tweedie variance power, not the learning rate, not the elastic net mixing
- **No monotone constraint support out of the box** — for regulator-facing rates, post-process or use a constrained boosting package
- **Unseen factor levels** — TDboost predicts the marginal mean for new levels; not always desired
- **Variable importance via `relative.influence`** is on the *raw* importance scale; for comparison across models, normalize

## Sources
- [[yang-2016-tdboost]] — defines the algorithm and the `TDboost` R package
