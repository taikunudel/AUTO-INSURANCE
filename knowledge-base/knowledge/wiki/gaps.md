# Wiki Gaps

Append-only log of moments where the agent had to make a substantive
modeling, statistical, or domain decision **without** wiki support.

Use this list to prioritize what to ingest next: each entry is a concrete
signal that a paper, package doc, or concept page is missing.

**Format:** one block per gap, newest at the top.

```
## [YYYY-MM-DD] <short-topic-slug>

- **Needed:** what knowledge the agent was missing
- **Surfaced by:** the task or question that exposed the gap
- **Expected page:** suggested filename under wiki/concepts/, wiki/sources/, or wiki/examples/
- **Workaround used:** what the agent did instead (cite source — paper, docs, training memory)
```

When the gap is filled (the suggested page is ingested), mark the block
with `**Resolved:** YYYY-MM-DD → [[NewPage]]` rather than deleting it,
so the history stays auditable.

---

## [2026-05-25] cplm-gini-signature-mismatch

- **Needed:** correct signature of `cplm::gini` in the installed cplm 0.7.12.1.
- **Surfaced by:** Auto-insurance benchmark (plan_v3.md) — Gini computation for all 5 models.
- **Expected page:** [[concepts/GiniIndex]] (already exists; **its Canonical Call block is stale**).
- **Workaround used:** Inspected `args(cplm::gini)` → real signature is
  `gini(loss, score, base = NULL, data, ...)` where `loss`, `score`, `base`
  are **character column names** referring to `data`, not raw vectors. Wrapper
  wrote a 3-column data.frame then called
  `cplm::gini(loss = ".loss", score = ".score", base = ".base", data = df)`.
  Returns an S4 object with `@gini` matrix (0–100 percent scale), not a list with `$gini`.

## [2026-05-25] mgcv-tweedie-link-argument-name

- **Needed:** correct `link` argument name for `mgcv::Tweedie(p, ...)` in mgcv 1.9-3.
- **Surfaced by:** Auto-insurance benchmark — Tweedie GAM procedure used `link.power = 0`
  and crashed with `unused argument (link.power = 0)`.
- **Expected page:** [[concepts/GeneralizedAdditiveModels]] (already exists; **its
  Canonical Call uses `tw()` so this issue doesn't manifest there, but a related
  example or page-update for fixed-p case is missing**).
- **Workaround used:** Inspected `args(mgcv::Tweedie)` → real signature is
  `Tweedie(p = 1, link = power(0))`. The `link` argument takes a power-link
  object (`stats::power(0)` gives log link), not a numeric. Fix:
  `mgcv::Tweedie(p = 1.7, link = stats::power(0))`.

---

## [2026-05-25] cplm::gini API mismatch
The wiki example examples/frees-meyers-cummings-2011-gini.R shows cplm::gini() called with numeric vectors as loss/score/baseline. The actual installed function (cplm 0.7-11+) requires column name strings and a data frame. The function returns an S4 gini object accessed via @gini[1,1]. The wiki example is marked UNVERIFIED but could mislead agents into using the wrong API.

## [2026-05-27] mgcv-tweedie-family-signature

- **Needed:** mgcv::Tweedie() function signature for version 1.9-3
- **Surfaced by:** auto-ins-2026-05-27-sonnet46-max; all GAM trials failed with "unused argument (link.power = 0)"
- **Expected page:** concepts/GeneralizedAdditiveModels.md — add "Argument Quirks" section documenting that mgcv 1.9-3 Tweedie() accepts `p` and `link` (defaulting to `power(0)` = log), but NOT `link.power` (which is statmod::tweedie's parameter name)
- **Workaround used:** Used `Tweedie(p = 1.7)` with no link argument (training memory + error inspection)

## [2026-05-27] cplm-gini-api

- **Needed:** cplm::gini() function API — argument types and return value structure
- **Surfaced by:** auto-ins-2026-05-27-sonnet46-max; all trials had eval_gini=NA because raw vectors were passed instead of column names
- **Expected page:** concepts/GiniIndex.md — add "Argument Quirks" section: gini() takes `loss`, `score`, `base` as CHARACTER column names (not vectors), `data` as a data.frame; returns an S4 object where the Gini value is at `g@gini[baseline_col, score_col]` as a scalar (0-100 scale)
- **Workaround used:** Inspected ?cplm::gini and error message; rewrote compute_gini to use data.frame API

## [2026-05-27] log-transform-eval-test-zeros

- **Needed:** Safe log-transform pattern when eval/test may have zeros in columns where training has min>0 (shift=0)
- **Surfaced by:** auto-ins-2026-05-27-sonnet46-max; fremtpl2 GLM t02/t03 failed with "NA/NaN/Inf in 'x'" 
- **Expected page:** concepts/DataPreprocessing.md or examples/log_transform_safe.R — document the pmax(pmax(x,0)+shift, 1e-10) pattern to prevent log(-Inf) when a column's training minimum is >0 but eval/test rows contain exact zeros
- **Workaround used:** Added inner pmax(..., 1e-10) guard before log() in both data_loader.R apply_prep and all 5 procedure predict closures

## [2026-05-27] tweedie-glm-irls-divergence

- **Needed:** Pattern for stabilizing Tweedie GLM IRLS convergence on skewed insurance splits
- **Surfaced by:** auto-ins-2026-05-27-sonnet46-max; fremtpl2 GLM t02,t03,t07,t08,t09 failed with "NA/NaN/Inf in 'x'" preceded by "step size truncated due to divergence" warning
- **Expected page:** concepts/GeneralizedLinearModels.md — add "Failure Modes" section: Tweedie GLM with log link can diverge on random splits with extreme values; fix by adding `mustart = rep(mean(y), nrow(data))` and `control = glm.control(maxit=100)` to the glm() call
- **Workaround used:** Set mustart to scalar mean(y) repeated n times; increased maxit to 100

## [2026-05-27] mgcv-smooth-k-fewer-unique-values

- **Needed:** Safe k selection for mgcv s() smooths when training columns may be near-constant
- **Surfaced by:** auto-ins-2026-05-27-sonnet46-max; sgautonb all 10 GAM trials failed with "A term has fewer unique covariate combinations than specified maximum degrees of freedom"  
- **Expected page:** concepts/GeneralizedAdditiveModels.md — add "Argument Quirks" for k selection: when a numeric column has ≤ 2 unique non-NA values in training, mgcv s() will error even with k=2; use a linear term instead of s(col, k=...) for such columns
- **Workaround used:** If n_uniq <= 2, return `col` (linear term) instead of `s(col, k=k_val)`
