---
title: "Insurance Premium Prediction via Gradient Tree-Boosted Tweedie Compound Poisson Models"
type: source
tags: [Tweedie distribution, gradient boosting, insurance, prediction models]
date: 2026-05-01
source_file: knowledge/raw/yang-2016-tdboost.md
---

## Summary
Yi Yang, Wei Qian, and Hui Zou propose a gradient tree-boosting algorithm for Tweedie compound Poisson models to enhance insurance premium predictions. This method, implemented in the R package "TDboost," can fit a flexible nonlinear Tweedie model and capture complex interactions among predictors. A simulation study and an auto insurance claim data application demonstrate its superior predictive performance over traditional models, addressing issues like adverse selection.

## Key Claims
- The traditional [[TweedieDistribution]] model's linear structure is too rigid, while gradient tree-boosting offers more flexibility for nonlinear data.
- The proposed method can significantly improve predictive accuracy and handle complex interactions between predictors.
- The approach is beneficial for addressing adverse selection in insurance premium predictions.

## Key Quotes
> "The need for nonlinear risk factors as well as risk factor interactions for modeling insurance claim sizes is well-recognized by actuarial practitioners, but practical tools to study them are very limited."

## Connections
- [[GradientTreeBoosting]] — Core algorithm proposed.
- [[R (programming language)]] — Implementation language for the proposed method.
- [[TweedieDistribution]] — Underlying statistical model.

## Contradictions
- None identified with existing content.
