# Wiki Index

This file is maintained by the LLM. Updated on every ingest.

## Overview
- [Overview](overview.md) — living synthesis across all sources

## Sources
- [Making Tweedie's Compound Poisson Model More Accessible](sources/delong-lindholm-wuthrich-2021-tweedie.md) — Poisson-Gamma vs Tweedie EDF; industry preference; neural-network extension
- [Evaluation of Tweedie Exponential Dispersion Model Densities by Fourier Inversion](sources/dunn-smyth-2008-tweedie-fourier.md) — Numerical density evaluation; `tweedie.profile` underpinnings
- [Risk Based Scores and the Gini Index](sources/frees-meyers-cummings-2011-gini.md) — Ordered Lorenz / Gini for insurance pricing
- [Tweedie's Compound Poisson Model With Grouped Elastic Net](sources/qian-2016-hdtweedie.md) — `HDtweedie` package; IRLS-BMD; grouped variable selection
- [Fitting Tweedie's Compound Poisson Model to Insurance Claims Data: Dispersion Modelling](sources/smyth-jorgensen-2002-tweedie-dispersion.md) — Tweedie DGLM; REML; mean+dispersion modeling
- [Fast Stable REML / ML Estimation of GAMs](sources/wood-2011-gam-reml.md) — `mgcv` direct smoothness selection
- [Insurance Premium Prediction via Gradient Tree-Boosted Tweedie Compound Poisson Models](sources/yang-2016-tdboost.md) — `TDboost` package; nonparametric Tweedie
- [Likelihood-based and Bayesian Methods for Tweedie Compound Poisson Linear Mixed Models](sources/zhang-2013-cplm.md) — `cplm` package; Laplace/AGQ/MCEM/MCMC

## Concepts

### Method / Software
- [Tweedie Distribution](concepts/TweedieDistribution.md) — exponential-dispersion family with power variance, point mass at zero
- [Poisson-Gamma Compound Model](concepts/PoissonGamma.md) — alternative parametrization; industry-preferred for frequency × severity
- [Generalized Linear Models](concepts/GeneralizedLinearModels.md) — baseline regression framework for EDF responses; note the IRLS convergence caveat for skewed Tweedie responses
- [Generalized Additive Models (GAMs)](concepts/GeneralizedAdditiveModels.md) — smooth function extensions of GLM
- [Double Generalized Linear Models (DGLM)](concepts/DoubleGeneralizedLinearModels.md) — joint mean + dispersion modeling
- [Gradient Tree-Boosting (for Tweedie)](concepts/GradientTreeBoosting.md) — boosted nonparametric Tweedie regression
- [Grouped Elastic Net (for Tweedie)](concepts/GroupedElasticNet.md) — group-level penalized variable selection
- [Gini Index (Ordered, for Insurance)](concepts/GiniIndex.md) — ranking-quality metric
- [Lorenz Curve (Ordered)](concepts/LorenzCurve.md) — graphical companion to ordered Gini

### Domain / Actuarial
- [Adverse Selection](concepts/AdverseSelection.md) — economic motivation for accurate risk segmentation
- [Frequency-Severity Decomposition](concepts/FrequencySeverityDecomposition.md) — actuarial convention for two-stage modeling
- [Tweedie Variance Power Estimation](concepts/TweedieVariancePowerEstimation.md) — why hardcoding `p` is harmful
- [AutoClaim Dataset](concepts/AutoClaimDataset.md) — canonical benchmark dataset

### Diagnostic
- [Calibration Plots (Decile Lift, Double Lift)](concepts/CalibrationPlots.md) — absolute-prediction quality checks
- [Leakage Audit](concepts/LeakageAudit.md) — sanity tests for suspiciously high Gini

## Entities
- [A. David Cummings](entities/ADavidCummings.md)
- [Bent Jørgensen](entities/BentJorgensen.md)
- [Edward W. (Jed) Frees](entities/EdwardWFrees.md)
- [Glenn Meyers](entities/GlennMeyers.md)
- [Gordon K. Smyth](entities/GordonKSmyth.md) — `statmod`, `tweedie` author
- [Hui Zou](entities/HuiZou.md)
- [Łukasz Delong](entities/LukaszDelong.md)
- [Mario V. Wüthrich](entities/MarioVWuthrich.md)
- [Mathias Lindholm](entities/MathiasLindholm.md)
- [Peter K. Dunn](entities/PeterKDunn.md) — `tweedie` co-author
- [Simon N. Wood](entities/SimonNWood.md) — `mgcv` author
- [Wei Qian](entities/WeiQian.md) — `HDtweedie` co-author
- [Yanwei Zhang](entities/YanweiZhang.md) — `cplm` author
- [Yi Yang](entities/YiYang.md) — `TDboost` lead author

## Examples
- [smyth-jorgensen-2002-tweedie-dispersion.R](examples/smyth-jorgensen-2002-tweedie-dispersion.R) — Tweedie GLM and DGLM on AutoClaim
- [qian-2016-hdtweedie.R](examples/qian-2016-hdtweedie.R) — Grouped elastic net via HDtweedie
- [yang-2016-tdboost.R](examples/yang-2016-tdboost.R) — Boosted Tweedie via TDboost
- [wood-2011-gam-reml.R](examples/wood-2011-gam-reml.R) — Tweedie GAM via mgcv
- [frees-meyers-cummings-2011-gini.R](examples/frees-meyers-cummings-2011-gini.R) — Ordered Gini computation and minimax
- [dunn-smyth-2008-tweedie-fourier.R](examples/dunn-smyth-2008-tweedie-fourier.R) — Density evaluation + variance-power profile
- [zhang-2013-cplm.R](examples/zhang-2013-cplm.R) — cpglm / cpglmm / bcplm fitting
- [delong-lindholm-wuthrich-2021-tweedie.R](examples/delong-lindholm-wuthrich-2021-tweedie.R) — Poisson-Gamma vs Tweedie GLM comparison

## Syntheses
_(none yet — query answers will be filed here)_
