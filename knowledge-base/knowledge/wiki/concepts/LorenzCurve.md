---
title: "Lorenz Curve (Ordered)"
type: concept
tags: [method, evaluation]
sources: [frees-meyers-cummings-2011-gini]
last_updated: 2026-05-15
---

## Definition
A graph of cumulative loss share (y-axis) vs cumulative premium share (x-axis), with both axes ordered by *relativity* = candidate score / base premium. Diagonal (45° line) = "line of equality" where each premium dollar collects the same fraction of losses. Curve below the diagonal = candidate score identifies an unprofitable subset; the further below, the more separation. Frees–Meyers–Cummings extend the classical Lorenz curve (from welfare economics, 1905) by sorting on a third variable (relativity) rather than the response itself.

## When to Use
- Visualizing how well a pricing model separates losses from premiums
- Communicating model value to non-technical stakeholders — the curve area is intuitive
- Diagnosing *where* a model fails: a curve that hugs the diagonal at the bottom but dips at top means the model only adds value for high-relativity policies

## When NOT to Use
- For absolute calibration (predicted ≠ observed mean) — Lorenz is rank-only
- For binary outcomes — ROC curve is the analog
- Without context — a Lorenz curve alone doesn't say whether the model is good *enough*; pair with [[GiniIndex]] for a summary number

## Canonical Call
```R
library(cplm)

result <- cplm::gini(loss = y_true, score = y_score, baseline = y_base)
plot(result)                    # ordered Lorenz curve

# Or, manually:
df <- data.frame(loss = y_true, score = y_score, base = y_base)
df <- df[order(df$score / df$base), ]
df$cum_prem <- cumsum(df$base)  / sum(df$base)
df$cum_loss <- cumsum(df$loss) / sum(df$loss)
plot(df$cum_prem, df$cum_loss, type = "l")
abline(0, 1, lty = 2)
```
See `[[examples/frees-meyers-cummings-2011-gini]]`.

## Key Hyperparameters
None — the curve is deterministic given (loss, score, baseline).

## Common Pitfalls
- **Sorting on `score` directly instead of `score / baseline`** — produces the classical (not ordered) Lorenz curve. The relativity ordering is the whole point.
- **Equal-weight points vs premium-weight points on the x-axis** — ordered Lorenz uses premium weights (sum of `baseline_i`); a uniform x-axis is the classical curve
- **Reading the curve without considering the baseline** — a model can look great vs constant baseline and poor vs a slightly better model

## Sources
- [[frees-meyers-cummings-2011-gini]] — defines the ordered Lorenz curve for insurance
