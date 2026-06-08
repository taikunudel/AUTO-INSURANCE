---
title: "Tweedie's Compound Poisson Model With Grouped Elastic Net"
type: source
tags: [method, HDtweedie, tweedie, regularization, insurance]
date: 2016-05-01
source_file: knowledge/raw/papers/qian-2016-hdtweedie.md
---

## Summary
Qian, Yang, and Zou propose a grouped elastic net penalty for Tweedie GLMs and implement it in the R package `HDtweedie`. The algorithm is a two-layer loop: an outer Iteratively Reweighted Least Squares (IRLS) wrapping an inner Blockwise Majorization Descent (BMD). Integrates the "strong rule" for path speedup. Designed for high-dimensional insurance pricing where many correlated predictors and dummy-coded categoricals are present.

## Canonical API
```R
library(HDtweedie)

# x: numeric design matrix (NO intercept column, NO factor columns — pre-expand)
# group: integer vector of length ncol(x), giving group index per column
# y: nonnegative response (claim amount, exposure-adjusted)
cv_fit <- cv.HDtweedie(
  x      = x_train,
  y      = y_train,
  group  = group_vec,
  p      = 1.5,        # Tweedie variance power, in (1, 2)
  alpha  = 0.7,        # mixing: 1 = grouped lasso, 0 = grouped ridge
  weights = NULL,      # default 1/n per obs; pass exposures if needed
  nfolds = 5
)

# Prediction REQUIRES the s= argument — see Argument Quirks
y_hat <- predict(cv_fit, newx = x_test, s = "lambda.min", type = "response")

# Active set
beta_hat <- coef(cv_fit, s = "lambda.min")
n_active <- sum(beta_hat != 0) - 1   # exclude intercept
```

See `[[examples/qian-2016-hdtweedie]]` for the full pipeline against `cplm::AutoClaim`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended | Sensible grid |
|---|---|---|---|---|
| `p` | Tweedie variance power | 1.5 | profile via `tweedie.profile`; never hardcode | {1.3, 1.5, 1.7} |
| `alpha` (τ in paper) | L1/L2 mix, `0 < α ≤ 1` | 1 (pure grouped lasso) | 0.5–0.7 when predictors are correlated | {0.5, 0.7, 1.0} |
| `group` | grouping vector | none — required | one block per categorical (all dummies together); polynomial terms grouped per base variable | — |
| `nfolds` | CV folds | 5 | 5–10 | 5, 10 |
| `weights` (v_i) | obs weights | `1/n` | exposure-proportional in actuarial use | — |
| `pf` (paper's w_j) | group penalty weights | `sqrt(p_j)` | leave default unless adaptive weighting | — |

## Argument Quirks
- **`x` must be a numeric matrix with no intercept column.** `cv.HDtweedie` adds the intercept internally. Passing `model.matrix(~ .)` directly will include an unpenalized intercept column that breaks groups.
- **Factor columns are not accepted.** Convert to dummies first (`model.matrix(~ . - 1)`), then build `group` to keep all dummies of one factor in the same block.
- **`predict.cv.HDtweedie` silently returns a matrix of all-lambda predictions when `s` is omitted.** Always pass `s = "lambda.min"` (or `"lambda.1se"`). The benchmark scripts in `archive/auto-insurance-bench-*` get this right, but it is a common slip.
- `type = "response"` returns predictions on the original (mean) scale. `type = "link"` returns the linear predictor.
- Strong rule activates by default; turn off with `strong = FALSE` only for debugging.

## Failure Modes
- **Silent crash** when test set contains factor levels unseen in train — caller must drop or re-bucket them before forming the dummy matrix.
- Convergence failure when p is too close to 1 or 2 — keep p in (1.05, 1.95).
- Cross-validation can be unstable when claim distribution is very sparse (>95% zeros); use larger `nfolds` or stratified folds in that case.
- Group sizes that vary by 10× or more bias selection. Default penalty weight `sqrt(p_j)` partially corrects; adaptive weights help more.

## Code Example
See `[[examples/qian-2016-hdtweedie]]`.

## Domain Pitfalls
- **Group construction is the single most common error.** For a categorical with K levels, group ALL K-1 dummies into one block. For a polynomial expansion (e.g., AGE, AGE², AGE³), group all three terms.
- Polynomial expansion: scale the base variable first, then expand. Expanding raw years and then scaling breaks the orthogonality that the optimizer assumes.
- Exposure: pass via `weights`; never include `offset(log(exposure))` (the package does not parse offsets in formulas — it takes a matrix).
- The benchmark scripts use `group_vec <- 1:n_cols` (each column its own group) which **collapses the method to ordinary elastic net** — a separate issue worth fixing in `archive/auto-insurance-bench-*`.

## Connections
- [[GroupedElasticNet]] — core method
- [[IRLS-BMD]] — algorithm
- [[TweedieDistribution]] — distribution
- [[StrongRule]] — speedup
- [[WeiQian]], [[YiYang]], [[HuiZou]]

## Contradictions
None with existing wiki content.
