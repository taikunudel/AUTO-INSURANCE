---
title: "Calibration Plots (Decile Lift, Double Lift)"
type: diagnostic
tags: [evaluation]
sources: [frees-meyers-cummings-2011-gini]
last_updated: 2026-05-15
---

## What It Checks
Whether the model's *absolute* predictions match observed losses, segment by segment. Gini ([[GiniIndex]]) measures ranking quality but cannot detect systematic bias — a model that doubles every prediction has the same Gini but is unusable for pricing. Calibration plots catch that class of failure.

## Procedure
1. **Decile lift plot** — sort policies by predicted loss; split into 10 equal-count bins. Plot mean predicted vs mean observed per bin. Good calibration = both lines coincide.
2. **Double lift plot** — between two competing models A and B, sort by `pred_A / pred_B`; bin into deciles; plot the ratio of observed loss in each decile to model A's prediction vs model B's prediction. Surfaces *where* one model wins or loses.
3. **Calibration slope** — regress observed on predicted (linear); slope = 1 and intercept = 0 = perfectly calibrated. Slope < 1 = model over-discriminates (predicted spread > observed spread).
4. **Mean prediction check** — overall predicted mean must equal observed mean within sampling error; otherwise dispersion modeling is mis-fit.

```R
library(ggplot2)
df <- data.frame(pred = y_hat, obs = y_true)
df$decile <- cut(df$pred, breaks = quantile(df$pred, probs = 0:10/10),
                 include.lowest = TRUE, labels = 1:10)
agg <- aggregate(cbind(pred, obs) ~ decile, data = df, FUN = mean)
ggplot(agg, aes(x = as.integer(decile))) +
  geom_line(aes(y = pred), color = "blue") +
  geom_line(aes(y = obs),  color = "red") +
  labs(x = "Predicted decile", y = "Mean loss",
       title = "Decile lift (blue = predicted, red = observed)")
```

## Pass / Fail Thresholds
- **Decile means must lie within ±10% of each other** across the full range. Mismatches > 20% in any decile = redesign feature set.
- **Calibration slope** in `[0.9, 1.1]` is acceptable; outside that, model is mis-calibrated. Most boosted models need post-hoc calibration (isotonic regression on holdout).
- **Mean prediction / mean observed** should be in `[0.95, 1.05]` on holdout. If off by more, dispersion is wrong; check the variance power and exposure handling.

## When to Run
- **Always**, after computing Gini. Gini alone is insufficient.
- Before reporting any cross-model comparison — a high-Gini-but-miscalibrated model is *worse* in practice than a low-Gini-but-calibrated model
- During monitoring after deployment — calibration drift is the first symptom of distribution shift
