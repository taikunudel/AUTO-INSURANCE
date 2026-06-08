# Overview

This wiki captures the methodological foundation for **auto-insurance pure-premium modeling** using the Tweedie compound-Poisson family. Eight papers, published 2002–2021, cover the path from foundational distributional theory through high-dimensional regularization, nonparametric extensions, and modern Bayesian / mixed-model fitting — together with the canonical evaluation methodology (ordered Gini).

## Modeling spectrum

The eight sources together form a complete spectrum of how to fit a Tweedie response:

| Model family | Source | R package | When it wins |
|---|---|---|---|
| Tweedie GLM (single mean) | [[smyth-jorgensen-2002-tweedie-dispersion]] | `statmod` | Baseline; interpretable; small n |
| Tweedie DGLM (mean + dispersion) | [[smyth-jorgensen-2002-tweedie-dispersion]] | `dglm` | Inference matters; heteroscedasticity present |
| Poisson + Gamma (two GLMs) | [[delong-lindholm-wuthrich-2021-tweedie]] | `stats::glm` | Counts and amounts both observed; industry standard; neural-net friendly |
| Tweedie GAM (smooth nonparametric main effects) | [[wood-2011-gam-reml]] | `mgcv` | Nonlinear main effects; medium n |
| Grouped elastic net Tweedie GLM | [[qian-2016-hdtweedie]] | `HDtweedie` | High p; categorical groups; polynomial expansions |
| Boosted Tweedie | [[yang-2016-tdboost]] | `TDboost` | Interactions; large n; predictive ceiling |
| Bayesian / mixed Tweedie | [[zhang-2013-cplm]] | `cplm` | Hierarchical structure; uncertainty quantification |

## Cross-cutting concerns

- **Variance power `p`** is the single most impactful hyperparameter and should be *estimated*, not hardcoded — see [[TweedieVariancePowerEstimation]]. Most packages either accept `p` (`statmod::tweedie`, `cv.HDtweedie`, `TDboost`) or estimate it automatically (`mgcv::tw`, `cplm::cpglm`). The `tweedie::tweedie.profile` routine is the cross-package fallback for estimation.
- **Density evaluation** near `p = 1` or `p = 2` is numerically tricky. [[dunn-smyth-2008-tweedie-fourier]] provides the Fourier-inversion machinery used inside `tweedie`; series and inversion methods are complementary across the (p, y, φ) space.
- **Evaluation** uses the ordered Gini ([[frees-meyers-cummings-2011-gini]], implemented as `cplm::gini`). Always pair with [[CalibrationPlots]] — Gini is rank-only and misses absolute miscalibration. Suspiciously high Gini (> 0.5 on `cplm::AutoClaim`) should trigger a [[LeakageAudit]].
- **Convergence of the Tweedie GLM** — `glm()` fits by IRLS and can stop *before* convergence on skewed / zero-heavy responses, silently returning `NA`/`Inf` coefficients and worse-than-random predictions. Raise the IRLS iteration budget and supply an explicit starting value (both **dataset-dependent**, not a fixed recipe), and verify `fit$converged`. See the convergence pitfall in [[GeneralizedLinearModels]].
- **Adverse selection** is the economic reason the Gini index matters: refined scores capture better risks and leave competitors with worse pools ([[AdverseSelection]]).
- **Parametrization choice** — Poisson-Gamma vs Tweedie EDF — has real consequences for robustness and neural-network extensibility ([[delong-lindholm-wuthrich-2021-tweedie]]), even when the two are mathematically equivalent at the GLM level.

## What this wiki is *not*

- It does not cover modern ML extensions (XGBoost-Tweedie, neural Tweedie heads, deep mixture-of-experts pricing) beyond the 2021 paper's neural-network discussion. Adding those would expand the wiki — currently a gap that lint would surface.
- It does not cover rate-filing, regulatory, or fairness considerations — see future ingest plan.
- It does not cover reserving (the IBNR / claims-development side of actuarial work) — the same Tweedie machinery applies but the modeling targets are different.
