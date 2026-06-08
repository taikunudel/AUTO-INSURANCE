---
title: "Leakage Audit (for Insurance Claim Models)"
type: diagnostic
tags: [evaluation]
sources: [frees-meyers-cummings-2011-gini]
last_updated: 2026-05-15
---

## What It Checks
Whether the predicted-vs-observed performance reflects genuine model quality rather than information leakage from target into features, or test-set contamination from train-set transforms. Specifically catches the failure mode where Gini on `cplm::AutoClaim` jumps from ~0.35 (expected, published range) to ~0.69 (implausible).

## Procedure
1. **Sanity-baseline Gini** — fit an intercept-only model; its Gini on holdout should be ≈ 0 (≤ 0.02). If higher, sort order is leaking — check that test indices weren't used in train preprocessing.
2. **Held-out feature ranges** — for every numeric feature, verify `range(test)` ⊆ `range(train) ± 5%`. If a test value is far outside train range, scaling fit on train and applied to test will produce extrapolation that looks like signal.
3. **Mean-prediction check** — `mean(y_hat_test) / mean(y_true_test)` should be in `[0.95, 1.05]`. Sharply different means indicate that the response-derived feature leaked, or that the test rows were unintentionally filtered.
4. **Permutation sanity test** — randomly permute the test response; recompute Gini. Should drop to ≈ 0. If the "Gini" with shuffled labels is high, the score is correlated with row order, not with the response.
5. **Cross-run consistency** — refit on a different seed/split; Gini should stay within ±0.03 of the original. Stability outside that range = the model is over-fitting on split-specific noise OR there is a global preprocessing leak.

```R
# Sanity-baseline Gini against constant
constant_pred <- rep(mean(y_train), length(y_test))
cplm::gini(y_test, constant_pred, baseline = constant_pred)$gini  # ≈ 0

# Permutation
set.seed(42)
y_perm <- sample(y_test)
cplm::gini(y_perm, y_hat_test, baseline = constant_pred)$gini    # ≈ 0
```

## Pass / Fail Thresholds
- **Gini ≤ 0.5 on `cplm::AutoClaim`** is the rough plausibility ceiling for current published methods on this dataset. Anything > 0.55 → run the audit.
- **Intercept-only Gini** must be ≤ 0.02. Higher means sort order is informative — leakage.
- **Cross-seed Gini SD** > 0.05 = unstable; investigate split-dependent preprocessing.
- **Mean-prediction ratio** outside `[0.95, 1.05]` = miscalibration OR leakage; both warrant investigation.

## When to Run
- **Before reporting any unusually high Gini.** This is exactly the situation in `archive/benchmark_plan_qwen3.5-35b-a3b-medium-01` where GrpLasso/GrpNet/TDboost all returned ~0.69 vs the high-01 run's ~0.35 across the same dataset.
- After any preprocessing pipeline change
- Before any production deployment — catches the silent class of bugs that pass code review but break in practice
