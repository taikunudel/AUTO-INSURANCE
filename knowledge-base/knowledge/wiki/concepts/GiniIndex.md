---
title: "Gini Index (Ordered, for Insurance)"
type: concept
tags: [method, cplm, evaluation]
sources: [frees-meyers-cummings-2011-gini]
last_updated: 2026-05-15
---

## Definition
For insurance model evaluation, the *ordered* Gini index is twice the area between the ordered Lorenz curve and the 45° line. Policies are sorted by *relativity* (candidate score divided by base premium), and the Lorenz curve plots cumulative loss share vs cumulative premium share along that order. The Gini quantifies how much loss separation a candidate score achieves over a base premium — approximately twice the average expected profit from adopting the score (Frees–Meyers–Cummings 2011).

## When to Use
- Comparing pricing models when total-loss prediction accuracy is the goal
- When the loss distribution is heavily zero-inflated and skewed (MSE/MAE are dominated by tails)
- For regulator-facing model justification — Gini is widely accepted in actuarial contexts
- Pairing with calibration checks ([[CalibrationPlots]]) — Gini is rank-only, not calibration-aware

## When NOT to Use
- Alone — Gini doesn't catch miscalibration. A constant model has Gini ≈ 0 but useless predictions; a perfectly ranked but uncalibrated model has high Gini but wrong absolute predictions
- For pure binary classification — use AUC, KS, or precision-recall instead
- For very small n (< 1000) — asymptotic SE is unreliable; bootstrap

## Canonical Call
```R
library(cplm)

result <- cplm::gini(
  loss     = y_true,            # observed losses
  score    = y_score,           # candidate model prediction
  baseline = y_base             # reference (e.g., constant or older model)
)

result$gini       # the index in percent (0–100 scale)
result$se         # asymptotic standard error
plot(result)      # ordered Lorenz curve
```
See `[[examples/frees-meyers-cummings-2011-gini]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended |
|---|---|---|---|
| `baseline` | reference premium | — | constant (e.g., `rep(mean(loss), n)`) for first pass; competing model for comparative pass |
| sort order | by relativity = score / baseline | ascending | ascending |

The metric has no tuning hyperparameters — it's deterministic given inputs.

## Common Pitfalls
- **`gini(y_true, y_pred)` (the benchmark scripts' wrapper)** — the wrapper passes `baseline = rep(constant, n)` implicitly. Valid, but document it. If you intended to compare against a competing model, you need to pass that as `baseline`.
- **Different sort handling for ties** — for very discrete predictions, break ties deliberately before passing
- **Comparing Gini across datasets** — Gini depends on the loss distribution; cross-dataset comparison is misleading
- **Gini > 0.6 on AutoClaim** — published reasonable range for Tweedie/penalized methods is 0.30–0.45; values above 0.6 should trigger a [[LeakageAudit]]. The `medium-01` benchmark hit 0.69 — almost certainly a data-prep bug, not real performance
- **Treating Gini as a hypothesis test** — use the asymptotic SE: differences within 2 SEs are not significant

## Sources
- [[frees-meyers-cummings-2011-gini]] — defines the ordered Gini for insurance pricing
