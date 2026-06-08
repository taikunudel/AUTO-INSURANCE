---
title: "Grouped Elastic Net (for Tweedie)"
type: concept
tags: [method, HDtweedie, regularization]
sources: [qian-2016-hdtweedie]
last_updated: 2026-05-31
---

## Definition
A penalized GLM where coefficients are partitioned into pre-specified *groups* (typically: one group per categorical variable's dummies, or per variable's polynomial expansion) and a combined L2/L1 penalty is imposed group-wise. The L1 part forces entire groups to zero (variable selection at the group level); the L2 part smooths within selected groups and stabilizes when within-group predictors are correlated. For Tweedie response, the IRLS-BMD algorithm of [[qian-2016-hdtweedie]] solves the path efficiently.

## When to Use
- When predictors include categorical variables with many levels — group all dummies for one factor together so the variable is selected as a whole
- When polynomial or basis expansions are used — group all terms for one base variable
- When the number of predictors approaches or exceeds n — regularization is mandatory
- As a fast and well-calibrated alternative to forward/backward selection

## When NOT to Use
- When predictors are uncorrelated and few — plain GLM is simpler and equivalent
- When interactions among many predictors dominate the signal — boosting wins
- When grouping structure is unclear or arbitrary — the method's benefit comes from meaningful groups

## Canonical Call
```R
library(HDtweedie)

# Pre-condition: x is a numeric matrix (no intercept column, factors dummified)
cv_fit <- cv.HDtweedie(
  x      = x_train,
  y      = y_train,
  group  = group_vec,      # one entry per column; same int = same group
  p      = 1.5,
  alpha  = 0.7,            # 1 = pure grouped lasso, 0 = grouped ridge
  nfolds = 5
)

y_hat <- predict(cv_fit, newx = x_test, s = "lambda.min", type = "response")
```
See `[[examples/qian-2016-hdtweedie]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended |
|---|---|---|---|
| `group` | grouping vector | none — required | one block per categorical factor; per base variable for polynomials |
| `alpha` (τ) | L1/L2 mix, (0, 1] | 1 | 0.5–0.7 when within-group correlation is high |
| `p` | Tweedie variance power | 1.5 | profile from data |
| `pf` | per-group penalty weight | `sqrt(group_size)` | leave default for balanced groups; adaptive weights for unbalanced |
| `nfolds` | CV folds | 5 | 5–10 |

## Common Pitfalls
- **Unscaled numeric predictors → catastrophic group collapse.** `cv.HDtweedie`'s group penalty is *scale-sensitive*: when numeric predictors sit on very different scales, the penalty path can drive all but one or two groups to zero, so the fit keeps only ~1–2 active groups and underfits to **near-random Gini**. **Standardize every numeric predictor (center + unit variance) on the training split, then apply the same shift/scale to eval/test before building `x`.** Do this *explicitly* — do not assume the package's internal `standardize` argument is sufficient — and select the columns **programmatically from the data** (all numerics), never a hardcoded list, so the step transfers to any dataset. Self-check after fitting: if `n_active` collapses to ~1–2 with a near-zero Gini, suspect unscaled / ill-conditioned inputs and refit with a standardized `x`.
- **`group_vec <- 1:n_cols`** (each column its own group) collapses the method to ordinary elastic net — defeats the purpose. This is the bug in `archive/auto-insurance-bench-*/procedures/03_grplasso.R`.
- **Including the intercept column in x** — `cv.HDtweedie` adds it internally; including it in `x` produces wrong group sizes and an unpenalized but doubly-counted intercept
- **Factor columns in x** — not accepted; pre-dummify with `model.matrix(~ . - 1)` then build `group`
- **Omitting `s = "lambda.min"` in predict** — returns a matrix of predictions across all lambdas; silently breaks downstream
- **Unbalanced group sizes** — default `sqrt(p_j)` only partially corrects; very unbalanced (10×+) groups need adaptive weights

## Sources
- [[qian-2016-hdtweedie]] — defines the algorithm and `HDtweedie` R package
