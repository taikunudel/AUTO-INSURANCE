---
title: "Likelihood-based and Bayesian Methods for Tweedie Compound Poisson Linear Mixed Models"
type: source
tags: [Tweedie distribution, Bayesian methods, statistical inference, mixed models]
date: 2026-05-01
source_file: knowledge/raw/zhang-2013-cplm.md
---

## Summary
Yanwei Zhang's paper introduces several likelihood-based and Bayesian methods for Tweedie Compound Poisson Linear Mixed Models (CPLMM). These methods enable the estimation of variance functions, previously reliant on the quasi-likelihood framework, which is inadequate for specific statistical inference tasks. The paper explores Monte Carlo EM, Laplace approximation, and Adaptive Gauss-Hermite Quadrature techniques for improved estimation accuracy.

## Key Claims
- The [[TweedieDistribution]] is challenging due to intractable density functions, but is important for modeling data with exact zeros.
- Traditional quasi-likelihood methods are unsuitable for accurate variance function estimation in mixed models, necessitating likelihood-based methodologies.
- The paper introduces Monte Carlo EM and Bayesian methods like [[MarkovChainMonteCarlo]] as effective strategies for variance estimation in CPLMM.

## Key Quotes
> "Monte Carlo EM and MCMC methods accommodate more general random effects structures or non-Normal distributions, providing robust variance estimation."

## Connections
- [[TweedieDistribution]] — Core distribution discussed in mixed modeling.
- [[MonteCarloEM]] and [[MarkovChainMonteCarlo]] — Key computational strategies explored.
- [[LaplaceApproximation]] and [[Adaptive Gauss-Hermite Quadrature]] — Techniques leveraged for likelihood approximation.

## Contradictions
- None identified with existing content.
