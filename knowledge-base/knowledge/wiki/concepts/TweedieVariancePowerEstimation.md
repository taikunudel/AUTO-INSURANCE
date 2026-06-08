---
title: "Tweedie Variance Power Estimation"
type: concept
tags: [domain, actuarial, method]
sources: [dunn-smyth-2008-tweedie-fourier, zhang-2013-cplm, smyth-jorgensen-2002-tweedie-dispersion]
last_updated: 2026-05-15
---

## Definition
The variance power `p` in the Tweedie family controls the shape of the mean-variance relationship `Var(Y) = φ · μ^p`, where `1 < p < 2` corresponds to compound Poisson-gamma. Industry practice frequently hardcodes `p = 1.5` or `p = 1.7`; this is a shortcut, not a principled choice. The variance power has substantial impact on dispersion estimates, standard errors, and Gini SEs ([[zhang-2013-cplm]]).

## Why It Matters in Practice
- Wrong `p` gives wrong dispersion, which gives wrong standard errors, which gives wrong "is this coefficient significant" calls
- Hardcoded `p = 1.7` (the default in `archive/auto-insurance-bench-*`) is one of three credible explanations for the cross-run Gini variance between the benchmarks
- Different lines of business have different `p`: auto claims typically 1.4–1.6, homeowners 1.5–1.7, weather-related lines 1.6–1.8
- Once estimated on a stable book, `p` rarely needs to be re-estimated more than annually

## How to Handle in Code
```R
library(tweedie)
library(statmod)

# Profile likelihood over a grid of p
prof <- tweedie.profile(
  formula  = CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS + AREA,
  data     = train,
  p.vec    = seq(1.1, 1.9, by = 0.1),
  link.power = 0,                                # log link
  method   = "inversion",                         # safest for AutoClaim ranges
  do.plot  = TRUE
)
p_hat <- prof$p.max                               # MLE
ci    <- prof$ci                                  # 95% CI

# Refine with finer grid near the optimum
prof2 <- tweedie.profile(..., p.vec = seq(p_hat - 0.1, p_hat + 0.1, by = 0.02))

# Use the result in downstream models
fit <- glm(CLM_AMT ~ ., data = train,
           family = tweedie(var.power = prof2$p.max, link.power = 0))
```
See `[[examples/dunn-smyth-2008-tweedie-fourier]]`.

For mixed models, `cplm::cpglm()` / `cplm::cpglmm()` estimate `p` by default (Laplace or AGQ).

For GAM, `family = tw()` (lowercase) inside `mgcv::gam()` estimates `p` automatically.

## Common Mistakes
- **Hardcoding `p`** — never do this on a new dataset without first profiling. The benchmark scripts in `archive/auto-insurance-bench-*` hardcode `p = 1.7` across all models, which suppresses one axis of meaningful comparison.
- **Profiling on tiny grids** — `p.vec = seq(1, 2, by = 0.5)` misses the optimum; use 0.05–0.1 spacing and refine
- **Trusting the smoothed maximum on a flat profile** — when the data has little signal, the profile is flat and the maximum is dominated by smoothing artifacts. Check `do.smooth = FALSE` for the raw profile
- **Reusing `p` across portfolios** — auto-only `p` may not transfer to a multi-line book; re-profile when the loss distribution shifts

## Sources
- [[dunn-smyth-2008-tweedie-fourier]] — numerical method behind `tweedie.profile`
- [[zhang-2013-cplm]] — impact of `p` on inference; `cplm` estimates it
- [[smyth-jorgensen-2002-tweedie-dispersion]] — discusses orthogonality of `p` to `μ`
