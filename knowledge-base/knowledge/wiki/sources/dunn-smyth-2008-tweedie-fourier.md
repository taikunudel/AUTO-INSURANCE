---
title: "Evaluation of Tweedie Exponential Dispersion Model Densities by Fourier Inversion"
type: source
tags: [method, tweedie, numerical, density]
date: 2008-08-17
source_file: knowledge/raw/papers/dunn-smyth-2008-tweedie-fourier.md
---

## Summary
Dunn and Smyth provide a numerically reliable Fourier-inversion routine for evaluating Tweedie densities, which have no closed form for general `p ∉ {0, 1, 2, 3}`. The method uses Sidi's modified W-transformation to accelerate the highly oscillatory integral, combined with a rescaling identity that lets all evaluations be done at `y = µ = 1`. Complementary to the series-evaluation method (Dunn–Smyth 2005): each works best in different regions of `(p, y, φ)`. Together they cover the full parameter space to 10⁻¹⁰ accuracy. This is what powers `dtweedie()` in the `tweedie` R package.

## Canonical API
```R
library(tweedie)

# Density evaluation
d <- dtweedie(y = c(0, 1, 2.5),
              mu = 1.0,
              phi = 1.0,
              power = 1.5)        # power = p, in (1, 2)

# Profile likelihood for the variance power p — the canonical way to set p
prof <- tweedie.profile(
  formula  = CLM_AMT ~ AGE + BLUEBOOK + AREA,
  data     = train,
  p.vec    = seq(1.2, 1.8, by = 0.1),
  do.plot  = TRUE,
  link.power = 0,
  method   = "inversion"          # Fourier-inversion; alt: "series", "saddlepoint", "interpolation"
)
p_hat <- prof$p.max                # ML estimate of p
```

End-to-end: `[[examples/dunn-smyth-2008-tweedie-fourier]]`.

## Key Hyperparameters
| Name | Role | Default | Paper-recommended | Sensible grid |
|---|---|---|---|---|
| `power` (p) | variance power | none | profile via `tweedie.profile` | (1, 2) for compound Poisson |
| `method` | density evaluation | `"interpolation"` | `"inversion"` for large y / p near 2; `"series"` for small y | both — check agreement |
| `p.vec` | grid for `tweedie.profile` | 1.2, 1.3, ..., 1.8 | finer near optimum | 0.05 spacing |
| `link.power` | link function | 0 = log | 0 | 0 |

## Argument Quirks
- **`dtweedie(y, mu, phi, power)` — argument order matters; `power` is the variance index, not a link power.** Confusingly, `tweedie()` family in `statmod` uses `var.power` for the same thing.
- `method = "series"` fails when `y` is large or `phi` is small (terms in the infinite sum blow up before convergence). `method = "inversion"` is the safe fallback. The paper shows neither alone is universally accurate.
- `tweedie.profile` is slow — each value of `p` requires a full GLM fit. Use coarse grid first, then refine.
- `do.smooth = TRUE` (default) fits a quadratic to the profile; useful, but if the grid is too coarse the smoothed max is unreliable.

## Failure Modes
- **Density evaluation breaks near `p = 1` and `p = 2`** (boundary cases). Approach 1.05–1.95 if you need to be safe; outside that, you're at the boundary case (Poisson or Gamma) and should use those directly.
- Subtractive cancellation in `method = "series"` for `p` close to 2 — symptom: density returns negative or NA.
- `tweedie.profile` can return a flat profile if the data has no signal — interpret the maximum cautiously.

## Code Example
See `[[examples/dunn-smyth-2008-tweedie-fourier]]`.

## Domain Pitfalls
- Industry practice often hardcodes `p = 1.5` or `p = 1.7`. The Dunn–Smyth machinery is **the** principled way to estimate `p` from your data, and it usually matters: in the benchmark `archive/auto-insurance-bench-*` the hardcoded `p = 1.7` is one of three candidate explanations for the cross-run Gini variance.
- The paper's accuracy targets (10⁻¹⁰) far exceed what's needed for downstream GLM fitting (relative likelihood differences of 10⁻⁴ are inconsequential). Use `method = "interpolation"` for routine work; `"inversion"` only when other methods fail.

## Connections
- [[TweedieDistribution]] — what is being evaluated
- [[FourierInversion]] — algorithmic technique
- [[ProfileLikelihood]] — estimation of `p`
- [[TweedieVariancePowerEstimation]] — domain procedure
- [[PeterKDunn]], [[GordonKSmyth]]

## Contradictions
None with existing wiki content. (The earlier wiki claimed contradiction with [[smyth-jorgensen-2002-tweedie-dispersion]] — that was an LLM hallucination; the two papers are complementary, not contradictory.)
