---
title: "Efficient Smoothing for Generalized Additive Models"
type: source
tags: [Generalized Additive Models, smoothing, statistics, numerical methods, GAMM]
date: 2026-05-01
source_file: knowledge/raw/wood-2011-gam-reml.md
---

## Summary
Simon N. Wood introduces the first computationally efficient method for direct smoothness selection in Generalized Additive Models (GAMs). The paper critiques existing methods like Performance Oriented Iteration and PQL, proposing a new approach to GAM estimation and smoothness selection that is stable, reliable, and computationally efficient.

## Key Claims
- Existing methods for GAM smoothness selection such as Performance Oriented Iteration and PQL suffer from convergence issues and inefficiency.
- The proposed method directly optimizes smoothness selection criteria, achieving greater reliability and computational efficiency.
- Integration with step reduction procedures enhances the practical stability of GAM fitting.

## Key Quotes
> "General fitting methods for GAMs should simply work, without the need for tuning."

## Connections
- [[GeneralizedAdditiveModels]] — Central topic of the paper.
- [[Smoothing]] — Key statistical technique addressed.
- [[R (programming language)]] — Used for the implementation of the proposed method.

## Contradictions
- Contradicts claims in existing sources about the reliability of some [[GeneralizedAdditiveModels]] estimation techniques.
