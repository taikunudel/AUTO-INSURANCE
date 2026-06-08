---
title: "Adverse Selection"
type: concept
tags: [domain, actuarial]
sources: [frees-meyers-cummings-2011-gini, yang-2016-tdboost, delong-lindholm-wuthrich-2021-tweedie]
last_updated: 2026-05-15
---

## Definition
The condition where, under asymmetric information, low-risk insureds withdraw from an insurer that charges above their expected loss while high-risk insureds stay, dragging the portfolio toward the latter. In pricing terms: if a competitor adopts a more refined risk-segmentation score and you don't, your good risks switch to them — leaving you with the bad risks and inadequate premium to cover them.

## Why It Matters in Practice
- Adverse selection is the *economic* reason that the ordered Gini index ([[GiniIndex]]) exists. Twice the area between the curves quantifies how much profit you leave on the table by not refining your score.
- Whichever model has the *highest* Gini against a constant baseline is hardest to attack via adverse selection. The "minimax" Gini strategy ([[frees-meyers-cummings-2011-gini]] Section 3.3) picks the score least vulnerable across all competitor scenarios.
- Tweedie GLM's linear structure can be too rigid to capture genuine non-monotonic risk (e.g., age) — which means competitors using GAM/boosting can extract the good young drivers. This is the core motivation for [[yang-2016-tdboost]].

## How to Handle in Code
- Evaluate every candidate model with `cplm::gini(loss, score, baseline)` against (a) a constant baseline and (b) every competing model
- Tabulate the Gini matrix; pick the model with the smallest maximum Gini-against-it (paper's "minimax" rule)
- For deployment: monitor the realized loss ratio by score band over time. If high-score policies' loss ratio drifts up while low-score drifts down, that's adverse-selection in action
- Don't conflate adverse selection with calibration error — they require different fixes

## Common Mistakes
- **Treating adverse selection as a modeling-accuracy problem alone** — it's a *relative* problem (you vs competitors). Even an accurate model leaks profit if your competitor is *more* accurate.
- **Optimizing only Gini-against-constant** — this maximizes profitability in isolation. The minimax framing accounts for competitor sophistication.
- **Ignoring downstream policy-retention impact** — adverse selection manifests in renewal patterns; the modeling team should partner with the retention team to close the loop.

## Sources
- [[frees-meyers-cummings-2011-gini]] — formal connection to ordered Gini
- [[yang-2016-tdboost]] — argues nonparametric models reduce adverse-selection exposure
- [[delong-lindholm-wuthrich-2021-tweedie]] — motivates parametrization choice in terms of practical robustness
