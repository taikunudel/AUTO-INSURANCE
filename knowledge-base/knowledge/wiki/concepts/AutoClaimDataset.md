---
title: "AutoClaim Dataset (cplm::AutoClaim)"
type: concept
tags: [domain, actuarial, reference]
sources: [zhang-2013-cplm, yang-2016-tdboost]
last_updated: 2026-05-15
---

## Definition
The canonical benchmark dataset for Tweedie/insurance regression in R, shipped as `cplm::AutoClaim`. From Yip and Yau (2005), originally an auto insurance claim panel with 10,296 policy-year records and 29 variables. The conventional filter for "new customers only" (`IN_YY == 1`) yields 2,812 rows; this is what every benchmark in `archive/auto-insurance-bench-*` uses.

## Why It Matters in Practice
- Reproducibility — every paper benchmarking Tweedie methods on real data uses this or a sibling dataset. Comparisons are otherwise apples-to-oranges.
- It is *small* — 2,812 rows × 28 features. High-dimensional methods like [[GroupedElasticNet]] are not really stressed.
- Heavily zero-inflated — most policies have CLM_AMT = 0. Makes it a good Tweedie testbed but a *bad* test for absolute-calibration metrics.
- Published Gini on this filtered version is in the 0.30–0.45 range across well-tuned Tweedie/penalized methods. Values >0.5 are implausible and should trigger a [[LeakageAudit]].

## How to Handle in Code
```R
library(cplm)
data("AutoClaim", package = "cplm")

# Standard filter
new_customers <- AutoClaim[AutoClaim$IN_YY == 1, ]   # 2812 rows
str(new_customers)

# Response and main features
# CLM_AMT       : total claim amount (Tweedie response)
# CLM_FREQ5     : count of claims in past 5 years
# EXPOSURE      : not in cplm version directly; some derived datasets add it
# AGE, BLUEBOOK, INCOME, MVR_PTS, KIDSDRIV, HOMEKIDS, NPOLICY, TRAVTIME : numeric
# AREA (Urban/Rural), GENDER, MARRIED, JOBCLASS, etc. : categorical

# Recommended transforms (used in the benchmarks)
df <- new_customers
df$BLUEBOOK_LOG <- log(df$BLUEBOOK)
df$INCOME_LOG   <- log(df$INCOME + 10)                # +10 because INCOME contains 0s

# Scaling (fit on train, apply to test)
scale_cols <- c("AGE", "BLUEBOOK_LOG", "INCOME_LOG", "TRAVTIME")
```

## Common Mistakes
- **Using all 10,296 rows when prior literature uses the `IN_YY == 1` filter** — your Gini is then not comparable to published results
- **Scaling test set with test-set statistics** — biases evaluation; fit scaling on train, apply to test
- **Treating `AREA` (or similar categoricals) as numeric** — silent bug; always coerce to factor explicitly
- **Forgetting `log(INCOME + c)` for the zero rows** — `log(0) = -Inf`; the `+10` adjustment is the conventional choice in this dataset's literature
- **Filtering zero-claim rows before fitting Tweedie** — defeats the entire purpose; Tweedie absorbs zeros (see [[TweedieDistribution]])

## Sources
- [[zhang-2013-cplm]] — the `cplm` R package that ships this dataset
- [[yang-2016-tdboost]] — example application in Section 6
