# LIVE WIKI — model-robustness update (2026-05-31), label `vs-053026`

This is the **live** wiki the benchmark reads (`knowledge/wiki/`). It is the **"after"
arm** of a wiki-effect experiment. The frozen "before" snapshot is `../wiki-053026/`
(see its `CLAUDE.md` for the post-mortem on what this version fixes).

> Maintenance workflows (ingest / query / lint / health / graph) are unchanged and still
> governed by the repo-root `llm-wiki-agent/CLAUDE.md`. This file only records the
> content change and the experiment it supports.

## Purpose of this version

The completed benchmark showed the previous wiki (`../wiki-053026/`) gave a Tweedie GLM
recipe that **looked correct but omitted the two fit-control settings that govern
convergence**, so agents who relied on it produced silently-diverging GLMs
(`NA`/`Inf` coefficients → worse-than-random Gini) on the harder datasets. This version
**documents that caveat — together with the other model-failure modes the benchmark
surfaced (grouped-lasso feature scaling, GAM smooth-basis sizing)** — so we can test the
next question: *if the wiki names these failure modes, do the models learn to avoid them?*

## What changed vs `../wiki-053026/`

Three model-failure modes the benchmark surfaced are now documented — each on a *different
model type*, so the A/B effect stays attributable per model:

1. **Tweedie-GLM IRLS convergence** — two control knobs: the IRLS **iteration limit**
   (`control = glm.control(maxit = ...)`) and the **initialization** (`mustart`, or
   warm-start `start`).
2. **Grouped-lasso (HDtweedie) feature scaling** — unscaled numeric predictors let the
   group penalty collapse to ~1–2 active groups (near-random Gini); standardize all
   numerics and verify `n_active`.
3. **GAM smooth-basis sizing** — a smooth's `k` above a covariate's unique-value count is a
   hard `mgcv` crash; cap `k` per column from the data, or drop to a linear term.

Edits:

| Page | Change |
|---|---|
| `concepts/GeneralizedLinearModels.md` | New **Common Pitfalls** bullet on IRLS stopping before convergence (silent `NA`/`Inf`, negative Gini); two new **Key Hyperparameters** rows (`control`, `mustart`/`start`). |
| `concepts/TweedieDistribution.md` | New **Common Pitfalls** bullet: the compound-Poisson response makes `glm()` IRLS prone to non-convergence; raise iterations + supply a start; check `fit$converged`. |
| `overview.md` | New **Cross-cutting concerns** bullet on Tweedie-GLM convergence. |
| `index.md` | GLM one-liner now flags the convergence caveat. |
| `examples/smyth-jorgensen-2002-tweedie-dispersion.R` | Tweedie `glm()` call now sets `control = glm.control(maxit = ...)` **and** `mustart`, checks `fit$converged`; scaling block generalized to **all numeric predictors** (no hardcoded list). |
| `concepts/GroupedElasticNet.md` | New **Common Pitfalls** bullet: unscaled numerics → group-penalty collapse to ~1–2 active groups → near-random Gini; standardize all numerics, verify `n_active`. |
| `concepts/GeneralizedAdditiveModels.md` | New **Common Pitfalls** bullet: `k` above a covariate's unique-value count is a hard `mgcv` crash; cap `k = min(desired, n_unique − 1)` per column or use a linear term. |
| `examples/qian-2016-hdtweedie.R` | Scaling generalized to **all numeric predictors** (no hardcoded list) + an `n_active <= 2` collapse warning. |

## Governing principle — all wiki knowledge must be DATASET-INDEPENDENT

Every page, pitfall, and example here must encode **model / method** knowledge that holds
for *any* dataset. This is not a style preference — it mirrors real use: the agent is
always handed a **new dataset** and asked to auto-build a model, so the only thing that
varies per task is the **data**. The wiki is the constant (how the models and packages
behave); the data is the variable the agent inspects fresh each time. When adding or
editing knowledge:

- **Document the failure mode and its *mechanism*, never a tuned value.** Say *"raise the
  IRLS iteration budget and supply a start; watch the non-convergence warning"* — never
  *"use maxit = N for dataset X."* The right value is dataset-dependent and must be derived
  from the data and the model's own warnings.
- **No dataset-specific constants, column names, or thresholds in prose.** The only numeric
  literal allowed in an example (e.g. `irls_budget <- 100L`) must be labeled a *starting
  point to tune*, not a recipe.
- **Examples show *patterns*, not hardcoded recipes.** Detect numeric columns, unique-value
  counts, group structure, etc. **programmatically from the data** — never a hardcoded list
  like `scale_cols <- c("AGE", ...)`. (Both example scripts were brought to this standard
  in the 2026-05-31 edit.)
- **The agent deals with the data; the wiki teaches the model.** If a fix can only be
  written as a dataset-specific number, it does **not** belong in a concept page — it
  belongs in the agent's data-inspection / debugging loop, surfaced from execution output.

## Relationship to the leakage-quarantine policy

The workspace policy (`/Users/theo/Downloads/auto-insurance/CLAUDE.md`) normally forbids
promoting `gaps.md` content into concept pages, because doing so contaminates the
generalization measurement. **This update intentionally does that**, as a *new and
separate* experimental arm — not a violation of the original test. The original arm is
preserved untouched and reproducible in `../wiki-053026/`. Treat the two folders as the
two conditions of an A/B test:

- `../wiki-053026/` — caveat absent (original generalization arm; already-collected results)
- `knowledge/wiki/` (this folder) — caveat present, described generally (new arm to run)
