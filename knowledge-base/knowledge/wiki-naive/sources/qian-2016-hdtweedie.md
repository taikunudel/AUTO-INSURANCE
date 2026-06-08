---
title: "Tweedie's Compound Poisson Model With Grouped Elastic Net"
type: source
tags: [Tweedie distribution, elastic net, insurance, variable selection, GLM]
date: 2026-05-01
source_file: knowledge/raw/qian-2016-hdtweedie.md
---

## Summary
Wei Qian, Yi Yang, and Hui Zou explore the application of the [[GroupedElasticNet]] method to [[TweedieDistribution]], effective for datasets with probability mass at zero and right-skewed distribution. This method accommodates the complexities of high-dimensional data within the context of the [[GeneralizedLinearModels]], using a new algorithm implemented in the [[R (programming language)]] package HDtweedie.

## Key Claims
- The grouped elastic net method effectively selects variables and fits models in the presence of highly correlated predictor variables.
- The proposed two-layer algorithm embeds a [[BlockwiseMajorizationDescent]] method into an [[IterativelyReweightedLeastSquare]] strategy, enhancing computational efficiency.
- The methodology aims to improve insurance premium prediction by utilizing a robust variable selection process.

## Key Quotes
> "The proposed algorithm is implemented in an easy-to-use R package HDtweedie, and is shown to compute the whole solution path very efficiently."

## Connections
- [[GroupedElasticNet]] — Key computational strategy for variable selection.
- [[IterativelyReweightedLeastSquare]] — Strategy used for algorithmic efficiency.
- [[TweedieDistribution]] — Underlying model discussed.
- [[Insurance]] — Example application field.

## Contradictions
- None identified with existing content.
