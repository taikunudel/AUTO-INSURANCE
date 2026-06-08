---
title: "Poisson-Gamma Compound Model"
type: concept
tags: [method, distribution]
sources: [delong-lindholm-wuthrich-2021-tweedie, smyth-jorgensen-2002-tweedie-dispersion]
last_updated: 2026-05-15
---

## Definition
A two-stage model for aggregated insurance losses: claim *count* `N ~ Poisson(λw)` with exposure `w`, and individual claim *sizes* `Z_j ~ Gamma(γ, c)` i.i.d. The total loss `S = Σ Z_j` is then compound Poisson–gamma distributed. Mathematically equivalent (in distribution) to the [[TweedieDistribution]] with `1 < p < 2`, but parametrized differently — frequency `λ` and severity `c/γ` are kept separate.

## When to Use
- Industry-standard parametrization for auto/home insurance pricing
- When claim *counts* AND individual claim *sizes* are observed (two GLMs to fit, more information used)
- When you need separate frequency and severity diagnostics — different covariates often affect them differently (e.g., a young driver may have higher *frequency* but similar *severity* as an older driver)
- For neural-network extensions ([[delong-lindholm-wuthrich-2021-tweedie]]) — two networks train more stably than a single Tweedie-loss network

## When NOT to Use
- Only the aggregate loss `S` is recorded (not `N`) — use Tweedie EDF / DGLM ([[smyth-jorgensen-2002-tweedie-dispersion]])
- When you need a single end-to-end model for downstream pipelines that consume one prediction

## Canonical Call
```R
# Frequency
fit_freq <- glm(N ~ AGE + AREA + offset(log(EXPOSURE)),
                data = train, family = poisson(link = "log"))

# Severity (conditional on N > 0; response = avg claim per claim; weight by N)
fit_sev <- glm(CLM_AMT_PER_CLAIM ~ AGE + AREA,
               data = subset(train, N > 0),
               family = Gamma(link = "log"),
               weights = N)

# Pure premium
pp <- predict(fit_freq, newdata = test, type = "response") *
      predict(fit_sev,  newdata = test, type = "response")
```
Verified end-to-end: `[[examples/delong-lindholm-wuthrich-2021-tweedie]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended |
|---|---|---|---|
| frequency link | for Poisson GLM | log | log |
| severity link | for gamma GLM | inverse | **log** (matches Tweedie equivalence theorem) |
| `offset(log(exposure))` | frequency exposure | required | required |
| `weights = N` | severity weighting | required | required (when y is per-claim average) |

## Common Pitfalls
- **Forgetting `weights = N` in the severity model** — large-N policies are then underweighted; predictions bias low for high-frequency segments
- **Including zero-claim rows in the severity GLM** — the gamma likelihood is undefined at zero; subset with `N > 0` first
- **Different covariate transforms for frequency vs severity** — fine in practice, but breaks the algebraic identity with Tweedie DGLM
- **Combining via sum instead of product** — pure premium = frequency × severity (per unit exposure), not frequency + severity

## Sources
- [[delong-lindholm-wuthrich-2021-tweedie]] — argues industry preference for this parametrization, esp. for neural networks
- [[smyth-jorgensen-2002-tweedie-dispersion]] — describes when Tweedie DGLM substitutes for Poisson-Gamma
