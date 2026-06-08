---
title: "Fitting Tweedie's Compound Poisson Model to Insurance Claims Data: Dispersion Modelling"
type: source
tags: [insurance, statistics, Tweedie distribution]
date: 2022-05-01
source_file: knowledge/raw/smyth-jorgensen-2002-tweedie-dispersion.md
---

## Summary
This paper by Gordon K. Smyth and Bent Jorgensen revisits the problem of creating fair tariffs based on insurance claims data, focusing on both mean and dispersion modeling using Tweedie's Compound Poisson model. It proposes utilizing double generalized linear models to increase tariff precision and describes methods for efficient parameter estimation.

## Key Claims
- The [[TweedieDistribution]] can model both the mean and dispersion of insurance claims, which improves tariff precision.
- Double generalized linear models handle cases where only total costs are recorded, enhancing the standard methods of [[Jorgensen]] and [[DeSouza]].
- The use of REML (Residual Maximum Likelihood) provides more accurate variance estimates in generalized models.

## Key Quotes
> "Modeling the dispersion increases the precision of the estimated tariffs." — on using double generalized linear models.

## Connections
- [[Jorgensen]] — Previous work on insurance claim modeling
- [[GeneralizedLinearModels]] — Central to the modeling approach
- [[TweedieDistribution]] — Core concept in the paper

## Contradictions
[]