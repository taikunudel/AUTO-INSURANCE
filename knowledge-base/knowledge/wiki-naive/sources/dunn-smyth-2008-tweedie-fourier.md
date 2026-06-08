---
title: "Evaluation of Tweedie Exponential Dispersion Model Densities by Fourier Inversion"
type: source
tags: [Tweedie distribution, Fourier inversion, statistics, numerical methods]
date: 2026-05-01
source_file: knowledge/raw/dunn-smyth-2008-tweedie-fourier.md
---

## Summary
This paper by Peter K. Dunn and Gordon K. Smyth studies numerical methods for evaluating the densities of Tweedie's exponential dispersion models using Fourier inversion. It presents a fast and accurate method leveraging acceleration techniques to handle oscillating integrands. The Fourier inversion method is complemented by a series evaluation method, with each having strengths in different parameter spaces.

## Key Claims
- Fourier inversion can numerically evaluate Tweedie model densities efficiently, even when closed-form density functions are unavailable.
- The paper introduces advanced integration methods, including the modified W-transformation, to evaluate oscillating integrals.
- The Fourier inversion and series evaluation methods are complementary, each excelling under different parameter conditions.

## Key Quotes
> "The approach can be brought to a successful conclusion by combining advanced integration methods with some analytic analysis of the integrand." — On the method's success.

## Connections
- [[TweedieDistribution]] — Core concept discussed for modeling data
- [[FourierInversion]] — Method applied for density evaluation
- [[GeneralizedLinearModels]] — Context where Tweedie models are useful

## Contradictions
- Contradicts claims from [[smyth-jorgensen-2002-tweedie-dispersion]] regarding the preferred methods under different parameter conditions.
