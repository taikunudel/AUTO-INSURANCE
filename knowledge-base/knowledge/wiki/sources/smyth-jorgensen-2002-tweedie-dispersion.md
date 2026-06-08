---
title: "Fitting Tweedie's Compound Poisson Model to Insurance Claims Data: Dispersion Modelling"
type: source
tags: [method, statmod, tweedie, dglm, insurance]
date: 2002-01-01
source_file: knowledge/raw/papers/smyth-jorgensen-2002-tweedie-dispersion.md
---

## Summary
Smyth and Jørgensen extend the Tweedie compound-Poisson GLM by fitting a *double* GLM that jointly models the mean **and** the dispersion. They observe that real claims data routinely violate the constant-dispersion assumption and that modeling dispersion via a second sub-GLM tightens tariff precision. The framework also handles the common case where only total cost is recorded (not claim counts). Demonstrated on the Swedish third-party auto portfolio.

## Canonical API
The paper itself uses base R + custom code. The closest production equivalent today is `statmod::tweedie` plus `dglm::dglm`, or `cplm::cpglm` with formula-based dispersion modeling.

```R
# Single-mean Tweedie GLM (no dispersion model) — statmod
library(statmod)
fit <- glm(CLM_AMT ~ ., data = train,
           family = tweedie(var.power = 1.5, link.power = 0))

# Double GLM (mean + dispersion) — dglm
library(dglm)
fit_dglm <- dglm(formula  = CLM_AMT ~ AGE + BLUEBOOK + AREA,
                 dformula = ~ AGE + AREA,                # dispersion submodel
                 family   = tweedie(var.power = 1.5, link.power = 0),
                 data     = train)
```

Verified end-to-end: `[[examples/smyth-jorgensen-2002-tweedie-dispersion]]` (marked `# UNVERIFIED` until run).

## Key Hyperparameters
| Name | Role | Default | Paper-recommended | Sensible grid |
|---|---|---|---|---|
| `var.power` (p) | mean-variance link, `Var(Y)=φμ^p` | none — must specify | profile likelihood over (1, 2) | {1.3, 1.5, 1.7} or `tweedie.profile()` |
| `link.power` | link function | 0 = log | 0 (log link) | 0 |
| dispersion formula | covariates for log(φ) | `~1` (constant) | as many factors as affect spread | start with main effects only |

## Argument Quirks
- `statmod::tweedie(var.power=1.7, link.power=0)` — `link.power=0` means log link. Setting `link.power=1` (identity) is almost always wrong for claims.
- `dglm` writes the dispersion submodel as a gamma GLM on unit deviances. Pre-condition: the response in the mean model must already have positive support (after the zero-mass via Tweedie).
- REML for dispersion uses `method="reml"` (paper's recommendation) — `method="ml"` produces biased φ estimates when n_params grows with n.

## Failure Modes
- Convergence stalls when p is mis-specified — symptom is dispersion submodel coefficients exploding. Diagnose with `tweedie.profile()`.
- If only total cost is observed (no claim counts), use the response = total cost per unit exposure and pass `weights = exposure`. Omitting weights silently inflates dispersion.
- Outliers in claim size dominate the dispersion fit. The paper notes REML mitigates but does not eliminate this — winsorize extreme claims or model on log scale.

## Code Example
See `[[examples/smyth-jorgensen-2002-tweedie-dispersion]]`.

## Domain Pitfalls
- Variance power `p = (α + 2) / (α + 1)` where α is the gamma shape. Profile `p` from data; do **not** hardcode 1.5 or 1.7 — see [[TweedieVariancePowerEstimation]].
- Exposure handling: `Y_i = Z_i / w_i` (claim per unit exposure). Pass `weights = w_i` to GLM; modeling raw `Z_i` without weights misallocates dispersion.
- The benchmark in `archive/auto-insurance-bench-*` hardcodes `var.power = 1.7` with no profiling — this is the first thing to fix.

## Connections
- [[TweedieDistribution]] — underlying distribution
- [[DoubleGeneralizedLinearModels]] — modeling framework
- [[REML]] — variance estimation method
- [[GeneralizedLinearModels]] — base
- [[GordonKSmyth]], [[BentJorgensen]]

## Contradictions
None with existing wiki content.
