---
title: "Double Generalized Linear Models (DGLM)"
type: concept
tags: [method, dglm]
sources: [smyth-jorgensen-2002-tweedie-dispersion, delong-lindholm-wuthrich-2021-tweedie]
last_updated: 2026-05-15
---

## Definition
A two-sub-GLM framework that jointly models the *mean* and the *dispersion* of a response distribution. The mean GLM has the usual form `g(μ_i) = x_i^T β`; the dispersion is modeled by a second GLM `g_d(φ_i) = z_i^T γ` on the unit deviances (which are approximately gamma-distributed). The two sub-GLMs are fitted iteratively. For Tweedie, this captures the fact that different covariates often drive expected loss vs loss volatility — which constant-dispersion GLM misses.

## When to Use
- When dispersion is plausibly non-constant — e.g., teenage drivers have both higher *expected* loss and higher *variance* of loss
- When inference (standard errors, hypothesis tests) matters, not just point predictions
- When [[TweedieDistribution]] is the response and the goal is industry-grade tariff precision
- As an alternative to fitting separate frequency and severity GLMs when only aggregate cost is available

## When NOT to Use
- When n is small (< 5000) — the dispersion submodel needs enough deviances to fit stably
- When the goal is purely point prediction and dispersion structure is irrelevant
- When neural networks are the modeling tool — Tweedie DGLM doesn't translate cleanly; [[delong-lindholm-wuthrich-2021-tweedie]] argues for Poisson + Gamma networks instead

## Canonical Call
```R
library(dglm)
library(statmod)

fit_dglm <- dglm(
  formula  = CLM_AMT ~ AGE + BLUEBOOK + AREA + MVR_PTS,
  dformula = ~ AGE + AREA,                       # dispersion sub-model
  family   = tweedie(var.power = 1.5, link.power = 0),
  data     = train,
  method   = "reml"                              # REML-adjusted; ML biased for n_params ~ n
)

# Predict mean
y_hat   <- predict(fit_dglm, newdata = test, type = "response")
# Predict dispersion
phi_hat <- predict(fit_dglm$dispersion.fit, newdata = test, type = "response")
```
See `[[examples/smyth-jorgensen-2002-tweedie-dispersion]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended |
|---|---|---|---|
| `dformula` | dispersion covariates | `~1` (constant) | start with main effects; add interactions if SE matters |
| `method` | estimation criterion | `"ml"` | `"reml"` (paper) |
| `family` | response distribution | gaussian | `tweedie(var.power, link.power=0)` |

## Common Pitfalls
- **Constant dispersion (`dformula = ~1`)** silently produces results equivalent to a plain GLM — defeats the purpose
- **ML instead of REML** when the number of mean-model parameters grows with n — REML mitigates the bias; the paper exists partly because of this
- **Dispersion submodel with too many covariates** — over-fits when count of deviances per dispersion parameter is small; start sparse
- **Interpreting dispersion-submodel coefficients as economic effects** — they are statistical noise descriptors, not premium-relevant per se. Pricing decisions still come from the mean submodel.

## Sources
- [[smyth-jorgensen-2002-tweedie-dispersion]] — defining application
- [[delong-lindholm-wuthrich-2021-tweedie]] — comparison vs Poisson-Gamma; computational improvements
