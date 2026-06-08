---
title: "Risk Based Scores and the Gini Index"
type: source
tags: [method, cplm, gini, evaluation, insurance]
date: 2011-04-27
source_file: knowledge/raw/papers/frees-meyers-cummings-2011-gini.md
---

## Summary
Frees, Meyers, and Cummings extend the classic Lorenz curve / Gini index to insurance pricing by sorting losses and premiums by a *relativity* `R = S(x) / P(x)` (alternative score divided by base premium). The resulting *ordered* Lorenz curve quantifies how much loss separation a candidate score `S` achieves beyond a base premium `P`. The associated Gini index is approximately twice the average expected profit from adopting `S`. Useful precisely because it can be computed against any base premium — including a constant — and so handles the zero-inflation that breaks classical metrics.

## Canonical API
```R
library(cplm)

# y_true:    observed losses (vector)
# y_score:   candidate score under evaluation
# y_base:    baseline / reference premium (often a constant or simpler model)
gini_result <- cplm::gini(
  loss     = y_true,
  score    = y_score,
  baseline = y_base       # if comparing two models, pass the older model here
)

gini_result$gini          # the index in percent
gini_result$se            # asymptotic standard error
plot(gini_result)         # the ordered Lorenz curve
```

For a *minimax* comparison across many candidate scores, loop over all (base, score) pairs and report the table — the paper's Section 3 example.

End-to-end: `[[examples/frees-meyers-cummings-2011-gini]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended | Sensible grid |
|---|---|---|---|---|
| `baseline` | reference premium | — | constant premium for first pass; competing model for second pass | both |
| sort direction | by relativity ascending | yes | yes | — |

The metric itself has no hyperparameters — it's deterministic given inputs.

## Argument Quirks
- **`gini(loss, score, baseline)` — NOT `(y_true, y_pred)`.** The relativity is computed internally as `score / baseline`. Passing the candidate score where baseline is expected silently produces a number that looks plausible but means nothing.
- For a single-model evaluation against a constant baseline, pass `baseline = rep(mean(loss), length(loss))` or `baseline = 1`. The benchmark scripts in `archive/auto-insurance-bench-*` define `gini_insurance(y_true, y_pred)` which collapses to score-vs-constant — this is a valid use case but should be labeled as such.
- Ties in relativity are broken by score order; for very discrete predictions (e.g., rounded), break ties before passing in.
- Asymptotic SE assumes ≥ ~1000 observations; under that, bootstrap.

## Failure Modes
- **Gini > 0.6 on `AutoClaim` should trigger a leakage audit.** Published Gini for Tweedie/penalized methods on this dataset is in the 0.30–0.45 range; the `medium-01` benchmark hit 0.69, almost certainly indicating a data-prep bug, not a real model improvement.
- Gini < 0.05 with SE near the point estimate → score is no better than baseline; do not adopt.
- A candidate score that achieves high Gini against one baseline but negative against another is *less* robust, not more — see the paper's minimax discussion.

## Code Example
See `[[examples/frees-meyers-cummings-2011-gini]]`.

## Domain Pitfalls
- Gini is **rank-based**, not calibration-based. A model can have excellent Gini and still be miscalibrated (predicted mean ≠ observed mean). Always pair Gini with a calibration check — see [[CalibrationPlots]].
- Adverse selection framing: if competitor adopts a refined score and you don't, your portfolio loses good risks. Ordered Lorenz quantifies *exactly* that exposure.
- Single Gini number is not a hypothesis test — use the asymptotic SE to compare candidate scores statistically. Differences within 2 SEs are not actionable.

## Connections
- [[GiniIndex]] — concept
- [[LorenzCurve]] — graphical companion
- [[AdverseSelection]] — economic motivation
- [[CalibrationPlots]] — complementary diagnostic
- [[EdwardWFrees]], [[GlennMeyers]], [[ADavidCummings]]

## Contradictions
None with existing wiki content.
