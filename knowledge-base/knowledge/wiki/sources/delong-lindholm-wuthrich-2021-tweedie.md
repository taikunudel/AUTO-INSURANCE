---
title: "Making Tweedie's Compound Poisson Model More Accessible"
type: source
tags: [method, tweedie, dglm, neural-network, insurance]
date: 2021-02-13
source_file: knowledge/raw/papers/delong-lindholm-wuthrich-2021-tweedie.md
---

## Summary
Delong, Lindholm, and Wüthrich revisit the choice between two equivalent parametrizations of the compound Poisson–gamma model: the *Poisson–Gamma* (two separate GLMs for frequency and severity) and the *Tweedie EDF* (one DGLM). Industry typically prefers Poisson–Gamma; the paper derives conditions under which the two give identical predictions, presents a new theorem that cuts computational cost of Tweedie's DGLM, and through GLM + neural-network examples shows that Poisson–Gamma is easier to calibrate and more robust — especially when extending to neural networks.

## Canonical API
```R
# ===== Approach A: Poisson-Gamma (two separate GLMs) =====
library(statmod)

# 1) Frequency (Poisson on claim counts, exposure offset)
fit_freq <- glm(
  N ~ AGE + BLUEBOOK + AREA + offset(log(EXPOSURE)),
  data   = train,
  family = poisson(link = "log")
)

# 2) Severity (gamma on average claim size, conditional on N > 0)
fit_sev <- glm(
  CLM_AMT_PER_CLAIM ~ AGE + BLUEBOOK + AREA,
  data   = subset(train, N > 0),
  family = Gamma(link = "log"),
  weights = N                                   # # of claims as weight
)

# Pure premium prediction
pred_pp <- predict(fit_freq, newdata = test, type = "response") *
           predict(fit_sev,  newdata = test, type = "response")

# ===== Approach B: Tweedie DGLM (single model) =====
# See [[smyth-jorgensen-2002-tweedie-dispersion]] for dglm() example
```

End-to-end: `[[examples/delong-lindholm-wuthrich-2021-tweedie]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended | Sensible grid |
|---|---|---|---|---|
| parametrization | Poisson-Gamma vs Tweedie DGLM | — | **Poisson-Gamma** for robustness, esp. with NNs | both — compare |
| frequency link | for Poisson GLM | log | log | log |
| severity link | for gamma GLM | inverse | **log** (matches Tweedie identity result) | log |
| `offset(log(exposure))` | exposure for Poisson | required | required | — |
| `weights = N` | for severity GLM | required (when y is per-claim) | required | — |

## Argument Quirks
- The paper's main theorem (Theorem 3.6/3.8): Poisson–Gamma with log links on both parts is *identical in distribution* to Tweedie DGLM under a specific covariate-space alignment. In practice, this rarely holds exactly because covariates are pre-processed differently for frequency and severity — which is fine and often desirable.
- Severity GLM **must condition on `N > 0`**. Including zero-claim rows breaks the gamma likelihood.
- Severity response is *average* claim size = `CLM_AMT / N`. Weight by `N` so the GLM treats it as a weighted observation.
- For neural network extensions: the paper's evidence is that fitting two separate networks (one for frequency, one for severity) is more stable than fitting a single Tweedie-loss network, because Tweedie's loss surface is harder.

## Failure Modes
- Poisson–Gamma: if you forget `weights = N` in the severity model, large-N policies are underweighted and predictions bias low for high-frequency segments.
- Tweedie DGLM: dispersion submodel is unstable when claim counts are very low (most data) — the unit deviances become noisy.
- Identity theorem fails silently if covariate transforms differ between frequency and severity (e.g., log-transform applied to one but not the other).

## Code Example
See `[[examples/delong-lindholm-wuthrich-2021-tweedie]]`.

## Domain Pitfalls
- The benchmark `archive/auto-insurance-bench-*` uses Tweedie-only models. This paper argues that running Poisson–Gamma alongside is the industry baseline — and worth including as a 6th model in the comparison.
- "Adverse selection" framing (also in [[frees-meyers-cummings-2011-gini]]) is the economic reason any of this matters.
- Neural network extensions: if you go beyond GLM, the paper strongly recommends Poisson + gamma networks over a single Tweedie-loss network. Tweedie loss with neural networks has known training instability around the boundary cases of `p`.

## Connections
- [[PoissonGamma]] — alternative parametrization
- [[TweedieDistribution]] — distribution
- [[DoubleGeneralizedLinearModels]] — DGLM approach
- [[NeuralNetworks]] — discussed extension
- [[FrequencySeverityDecomposition]] — domain framing
- [[LukaszDelong]], [[MathiasLindholm]], [[MarioVWuthrich]]

## Contradictions
None with existing wiki content. (The earlier wiki claimed "contradicts previous claims about traditional GLM superiority" — that was an LLM hallucination; this paper is descriptive comparison, not a claim of superiority.)
