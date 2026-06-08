# Wiki Log

Append-only chronological record of all operations.

Format: `## [YYYY-MM-DD] <operation> | <title>`

Parse recent entries: `grep "^## \[" wiki/log.md | tail -10`

---

## [2026-05-15] regen | Wiki regenerated under method-aware schema

Triggered by user request after archiving prior wiki to `wiki-naive/`.
Re-ingested all 8 sources from `raw/papers/` using the new schema's
Method/Software template (sources) and required-section concept templates.

Result:
- 8 source pages (was 8 — same coverage, ~5× content depth per page)
- 15 concept pages (was 17 — slightly fewer, but each with required
  sections; previous stubs of <500 chars all rewritten to spec)
- 14 entity pages (was 14)
- 8 example files (was 0 — entirely new directory `wiki/examples/`)
- Refreshed `index.md`, `overview.md`

Key differences vs `wiki-naive/`:
1. Every method source now has a `## Canonical API` section with the
   actual R call and argument names
2. Every method source carries a Key Hyperparameters table with paper-
   recommended values and sensible grids
3. Argument Quirks and Failure Modes capture the silent-failure surface
   (e.g., HDtweedie's `s = "lambda.min"` requirement, TDboost's
   `n.trees` selection, mgcv's `method = "REML"` vs `"GCV.Cp"`)
4. New diagnostic page type — `CalibrationPlots`, `LeakageAudit` —
   surface evaluation procedures the naive wiki had no place for
5. The `examples/` directory captures the full end-to-end pipeline for
   each method against `cplm::AutoClaim`. Marked `# UNVERIFIED` pending
   actual run; the schema requires verification before promotion.

## [2026-05-15] archive | Previous wiki preserved as wiki-naive/

Moved `wiki/` → `wiki-naive/` via `git mv` to preserve history for diff.
No content modifications; the directory now stands as a reference for
what the original (naive) ingest produced from the same 8 sources.

---

## [2026-05-15] ingest | Fitting Tweedie's Compound Poisson Model to Insurance Claims Data: Dispersion Modelling

Source: [[smyth-jorgensen-2002-tweedie-dispersion]]. Template: Method/Software.
Key claims: Tweedie DGLM jointly models mean + dispersion via two coupled GLMs;
REML beats ML for n_params growing with n; addresses cases where only total
cost is observed (not claim counts).

## [2026-05-15] ingest | Evaluation of Tweedie Exponential Dispersion Model Densities by Fourier Inversion

Source: [[dunn-smyth-2008-tweedie-fourier]]. Template: Method/Software.
Key claims: Tweedie densities have no closed form for general p; Fourier
inversion via modified W-transformation handles oscillating integrand;
complementary to series evaluation. Powers `tweedie::dtweedie` and
`tweedie.profile`. Resolves a hallucinated contradiction from the naive
wiki (dunn-smyth was NOT contradicting smyth-jorgensen).

## [2026-05-15] ingest | Risk Based Scores and the Gini Index

Source: [[frees-meyers-cummings-2011-gini]]. Template: Method/Software.
Key claims: ordered Lorenz / ordered Gini for insurance pricing; sort by
relativity = score / baseline; Gini ≈ 2 × average profit; minimax framing
across competing scores. Pair with [[CalibrationPlots]] — Gini is rank-only.

## [2026-05-15] ingest | Tweedie's Compound Poisson Model With Grouped Elastic Net

Source: [[qian-2016-hdtweedie]]. Template: Method/Software.
Key claims: grouped elastic net for Tweedie GLM via IRLS-BMD; `HDtweedie`
R package; strong rule for path speedup. New Argument Quirks section flags
silent failures the naive wiki missed (no intercept in x; factors must be
dummified; `s = "lambda.min"` in predict; group construction).

## [2026-05-15] ingest | Fast Stable REML / ML Estimation of GAMs

Source: [[wood-2011-gam-reml]]. Template: Method/Software.
Key claims: First computationally stable full-Newton method for direct GAM
smoothness selection. `method = "REML"` is the safe choice; the legacy
`"GCV.Cp"` default can silently fail. Implemented in `mgcv`.

## [2026-05-15] ingest | Insurance Premium Prediction via Gradient Tree-Boosted Tweedie Compound Poisson Models

Source: [[yang-2016-tdboost]]. Template: Method/Software.
Key claims: gradient boosting + Tweedie loss; profile likelihood for ρ, φ;
`TDboost` R package with partial-dependence plots. Hyperparameter spec
captures the paper's recommended shrinkage = 0.005 (not the package
default 0.001) and the `n.trees` CV-selection requirement.

## [2026-05-15] ingest | Likelihood-based and Bayesian Methods for Tweedie Compound Poisson Linear Mixed Models

Source: [[zhang-2013-cplm]]. Template: Method/Software.
Key claims: Laplace, AGQ, MCEM, MCMC for Tweedie CPLMM; `cplm` R package;
estimates p by default (vs PQL's hardcoded p). Ships the canonical
`AutoClaim` benchmark dataset.

## [2026-05-15] ingest | Making Tweedie's Compound Poisson Model More Accessible

Source: [[delong-lindholm-wuthrich-2021-tweedie]]. Template: Method/Software.
Key claims: Poisson-Gamma vs Tweedie EDF parametrizations are mathematically
equivalent under specific link/covariate alignment; industry prefers
Poisson-Gamma, especially for neural-network extensions where Tweedie loss
has training instabilities. Resolves a hallucinated contradiction from the
naive wiki (this paper does NOT claim Tweedie superiority).

## [2026-05-15] graph | Knowledge graph rebuilt

38 nodes, 84 edges (84 extracted, 0 inferred).
