---
title: "Likelihood-based and Bayesian Methods for Tweedie Compound Poisson Linear Mixed Models"
type: source
tags: [method, cplm, tweedie, mixed-models, bayesian]
date: 2013-01-01
source_file: knowledge/raw/papers/zhang-2013-cplm.md
---

## Summary
Zhang derives four likelihood-based and Bayesian estimation methods for Tweedie compound-Poisson linear mixed models (CPLMM): Laplace approximation, adaptive Gauss–Hermite quadrature (AGQ), Monte Carlo EM (MCEM), and MCMC. Unlike penalized quasi-likelihood (PQL), all of these enable estimation of the variance power `p` from the data — which the paper shows has large impact on dispersion estimates and downstream uncertainty. Implemented as the R package `cplm`, which also ships the `AutoClaim` dataset used in every benchmark in `archive/`.

## Canonical API
```R
library(cplm)

# Fixed-effects-only Tweedie GLM (estimates p)
fit_glm <- cpglm(
  formula = CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS + AREA,
  data    = train,
  link    = "log"
  # p is estimated by default; pass p = 1.5 to fix
)

# Mixed model — random intercept by some grouping factor
fit_mm <- cpglmm(
  formula  = CLM_AMT ~ AGE + BLUEBOOK + (1 | AREA),
  data     = train,
  link     = "log",
  optimizer = "nlminb"
)

# Bayesian — MCMC
fit_bayes <- bcplm(
  formula  = CLM_AMT ~ AGE + BLUEBOOK + (1 | AREA),
  data     = train,
  n.chains = 3,
  n.iter   = 10000,
  n.burnin = 2000
)

# Gini evaluation
cplm::gini(loss = test$CLM_AMT,
           score = predict(fit_glm, newdata = test, type = "response"),
           baseline = mean(train$CLM_AMT))
```

End-to-end: `[[examples/zhang-2013-cplm]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended | Sensible grid |
|---|---|---|---|---|
| `link` | link function | `"log"` | `"log"` for claims | `"log"`, `"identity"` (rare) |
| `p` (`var.power`) | variance power | estimated | estimate; if fixing, profile first | (1.05, 1.95) |
| `optimizer` (in `cpglmm`) | mixed-model fit | `"nlminb"` | `"nlminb"` or `"bobyqa"` | both |
| `nAGQ` (in `cpglmm`) | quadrature points | 1 (= Laplace) | 5–10 for better accuracy at cost of time | 1, 5, 10 |
| `n.iter` (in `bcplm`) | MCMC iterations | 1000 | 10000+ for stable inference | 5000–50000 |
| `n.chains` | MCMC chains | 1 | 3+ for convergence diagnostics | 3, 4 |

## Argument Quirks
- **`cpglm` estimates `p` by default** unless you pass `p` explicitly. `p.cpglm = NULL` triggers the profile.
- The `cplm` family of fitters use `formula` notation with `(1 | group)` for random effects — same as `lme4`. Don't confuse with `nlme`'s `random = ~ 1 | group`.
- `cpglm` returns S4; access slots with `@`, not `$`. Coefficients via `coef(fit)`, fitted values via `fitted(fit)`.
- The `AutoClaim` dataset has `IN_YY` indicator for "new customer" — the benchmarks filter to `IN_YY == 1` (2,812 rows). Using all rows is also valid but changes the population.
- `bcplm` priors are mildly informative by default; check `summary(fit_bayes)` Rhat and effective sample size before trusting results.

## Failure Modes
- **PQL is the silent failure mode this paper exists to fix.** If you fit a Tweedie mixed model and `p` is hardcoded, you have a PQL-equivalent model with all its bias. Always at least *profile* `p`.
- MCEM is computationally expensive; for n > 100k consider Laplace + nAGQ instead.
- Bayesian: poor MCMC mixing manifests as Rhat > 1.05 — increase iterations or reparameterize.
- AGQ with `nAGQ > 1` fails when random effects are crossed (only nested allowed).

## Code Example
See `[[examples/zhang-2013-cplm]]`.

## Domain Pitfalls
- `cplm::AutoClaim` is the canonical insurance benchmark. 2,812 rows × 28 features (filtered `IN_YY == 1`) is small — high-dimensional methods like HDtweedie are not really stressed here.
- Estimating `p` matters: the paper shows that hardcoding `p = 1.5` vs `p = 1.7` shifts dispersion estimates by ~30% on real data, with downstream consequences for standard errors and Gini SEs.
- The `cplm::gini()` interface is the reference implementation of [[frees-meyers-cummings-2011-gini]]'s metric — use it instead of rolling your own.

## Connections
- [[TweedieDistribution]] — distribution
- [[GeneralizedLinearMixedModels]] — model class
- [[LaplaceApproximation]] — estimation
- [[AdaptiveGaussHermiteQuadrature]] — estimation
- [[MonteCarloEM]] — estimation
- [[MarkovChainMonteCarlo]] — Bayesian
- [[AutoClaimDataset]] — canonical data
- [[YanweiZhang]]

## Contradictions
None with existing wiki content.
