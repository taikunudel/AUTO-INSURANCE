# Auto Insurance Pricing Model Benchmark — Agent Execution Plan (Concise)

## 0. No reuse of prior runs

This is a fresh-each-time benchmark. Every implementation run must:

- **Start from an empty workspace.** Do not copy code, scripts, models, predictions, fitted objects, or summary CSVs from any prior benchmark run, your own or anyone else's. The reference for what to build is this plan, not other people's results directories.
- **Never read, list, search, or reference `/Users/theo/Downloads/auto-insurance/do_not_read` or any path inside it.** This folder is explicitly off-limits. Do not `cat`, `ls`, `find`, `grep`, `head`, `tail`, `Read`, `Glob`, or otherwise inspect it under any circumstances. Treat its existence as if it were not there. This restriction is non-negotiable and independent of any other path-exclusion rule.
- **Not pre-populate `results/` with anything.** The orchestrator wipes any *unfinished* dataset directory on every invocation but **preserves dataset directories that are fully complete** from a prior run on the same workspace (50/50 successful trials, i.e. 5 models × 10 trials with status OK — see Section 8). Your scripts must not write into `results/` before the orchestrator runs.
- **Re-derive every artifact this run.** Models, predictions, predict-fn closures, summary tables — all of them must be the output of this run's procedure scripts, fitted on this run's API-served splits.
- **Treat all other runs — whether currently in progress or already finished — as completely out of scope.** This plan is routinely executed in parallel across multiple independent workspaces. No run may read, inspect, copy, or draw any inference from another run's workspace, results directory, logs, code, scripts, fitted objects, or outputs, regardless of whether that other run is still running or has fully completed. Do not reuse code from other runs — all scripts (`lib/`, `procedures/`, `agent/`) must be written from scratch using this plan as the sole reference. Every run is a sealed, self-contained unit.

Reusing prior runs is the single largest source of contamination across agent comparisons (different splits, stale preprocessing, leaked test labels). The orchestrator's wipe-on-start is a backstop; the primary defense is the agent following this directive.

---

## 1. Experiment overview

This experiment benchmarks five Tweedie-family regression models on an auto insurance claim dataset, measuring how well each model ranks policyholder risk. Data is served exclusively by the sealed eval API at `EVAL_API_URL`; the agent does not know the underlying data source, does not load any raw file or R-package dataset directly, and does not read the API's source code. All five models share the Tweedie compound Poisson loss family, which makes their predictions directly comparable via the Gini index of the ordered Lorenz curve — the standard insurance-pricing metric for risk segmentation.

The benchmark measures two things per model:

1. **Gini index** — predictive ranking quality, individual (not pairwise), with constant baseline premium M(x) ≡ 1.
2. **Success rate** — fraction of trials (out of 10) that produce a complete metric row.

**Datasets — all by default, in the canonical priority order below.** The eval API hosts several insurance datasets (`GET /datasets` lists them). By default the orchestrator runs the full 5-models × 10-trials benchmark on each dataset, one at a time, in this fixed order:

1. `autoclaim` — AutoClaim (Yip & Yau 2005), 10 papers
2. `fremtpl2` — French motor third-party liability, 11 papers
3. `bemtpl97` — Belgian motor third-party liability 1997, 5 papers
4. `ausprivauto` — Australian private motor 2004–2005, 3 papers
5. `swautoins` — Swedish third-party motor, 2 papers
6. `sgautonb` — Singapore auto 1993–2001, 2 papers
7. *Any additional datasets returned by `GET /datasets` that are not listed above run after these, in the order the API returned them.*

Per-dataset results land under `results/<dataset>/<model>/...` (see Section 6). To pin to a single dataset, set the `EVAL_DATASET` environment variable to its name; the orchestrator then runs only that one. The plan does not hardcode predictor names, transforms, or row counts — those are discovered at runtime from `GET /datasets/<dataset>/info` (Section 4).

**Reaching the eval API — localhost first, then `host.docker.internal`.**

1. Try `EVAL_API_URL` if it's explicitly set in the environment.
2. Otherwise try `http://localhost:8765`.
3. If localhost doesn't respond, try `http://host.docker.internal:8765`.
4. If both fail, halt with a clear error.

Each model is run **10 times**. The eval API holds a **single global test set** (~20% of rows, sealed labels) carved out once at startup — every trial scores against the same test set. The remaining ~80% is re-split per trial into train (~70%) and eval (~10%). Execution is **round-robin and strictly sequential**: round 1 runs all 5 models on `(train_1, eval_1)`, then round 2, and so on.

The agent saves test predictions as JSON files and the **grader** — who holds the API admin token — runs `POST /datasets/$EVAL_DATASET/score/<k>` afterward to compute the authoritative test Gini. The orchestrator calls `score_dataset()` immediately after each dataset's 50 trials complete, so `mean_test_gini` is populated before the agent moves to the next dataset.

---

## 2. The five models

**Tweedie GLM.** Generalized linear model with Tweedie compound Poisson family and log link. The mean function is strictly log-linear in the predictors. Rigid baseline — captures no nonlinearity or interactions unless features are manually engineered.

**Tweedie GAM.** Generalized additive model with Tweedie family. Each numerical predictor enters through a penalized smoothing spline; categorical predictors enter as factors. Captures arbitrary smooth main effects but interactions must be specified explicitly.

**GrpLasso.** Tweedie GLM with grouped lasso penalty. Predictors are partitioned into blocks (e.g., a categorical's dummy variables, or a numerical's polynomial expansion); the penalty selects or zeros out each block as a unit.

**GrpNet.** Tweedie GLM with grouped elastic net penalty. Same as GrpLasso but with an additional L2 component (mixing parameter τ < 1), which handles correlated blocks better.

**TDboost.** Gradient tree-boosted Tweedie compound Poisson model. Captures arbitrary nonlinearities and high-order interactions automatically.

---

## 3. Models and packages

**Packages required:** `statmod` (GLM), `mgcv` (GAM), `HDtweedie` (GrpLasso/GrpNet), `TDboost`, `cplm` (Gini metric).

**Tweedie power: use p = 1.7 for all five models** (fixed, not estimated — consistent across models for comparability).

**If a knowledge wiki exists at `/Users/theo/Downloads/auto-insurance/knowledge/wiki/`, consult it before writing any model code** — it will likely contain useful concepts and code (calling conventions, common pitfalls, Tweedie-specific arguments, the Gini calculation, the leakage audit). Navigate it independently; there is no prescribed reading order. Whether or not a wiki is present, adapt to whatever package signatures are installed and log any discrepancies — do not halt.

---

## 4. Dataset

**Source.** Splits are served by the sealed eval API. The agent does **not** load any raw dataset directly and does **not** read API source code. The plan does not name columns, transforms, or row counts — the agent must discover them at runtime.

**Discovery (verification step).** Before fitting anything, the agent:

1. `GET $EVAL_API_URL/datasets` → confirm `$EVAL_DATASET` appears in the list. Record the response.
2. `GET $EVAL_API_URL/datasets/$EVAL_DATASET/info` → record the manifest. Use these fields to drive everything downstream (do not hardcode):
   - `n_trials`, `ratios`, `total_rows`, `train_rows`, `eval_rows`, `test_rows`
   - `response_var` — name of the response column in train/eval CSVs (typically `"y"`)
   - `numeric_predictors`, `factor_predictors` — column names by type
   - `metric` — must be `"gini"` for this benchmark to apply

**Splits — fetched, not constructed.**

```r
api <- Sys.getenv("EVAL_API_URL_RESOLVED")
ds  <- Sys.getenv("EVAL_DATASET")
train_k <- read.csv(sprintf("%s/datasets/%s/splits/%d/train.csv", api, ds, k))
eval_k  <- read.csv(sprintf("%s/datasets/%s/splits/%d/eval.csv",  api, ds, k))
test_   <- read.csv(sprintf("%s/datasets/%s/splits/test.csv",     api, ds))   # global, no <k>
```

- `train` and `eval` carry the response column plus all predictors plus an opaque `row_id`.
- `test` carries predictors and `row_id` only — **no response column**.

**Preprocessing — agent's call, fit on train only.** After exploring the train side of trial 1, the agent decides what to apply, then **fits all preprocessing state on `train` only** and applies that state unchanged to `eval` and `test`. State includes: scaling means/SDs, factor levels, NA imputers, polynomial bases, any log/box-cox/winsorization the agent chose. Reasonable defaults to consider:

- Log-transform heavy-tailed non-negative numerics (use `log1p` to avoid `-Inf` on zero values).
- Median-impute numeric NAs using train medians.
- Factor levels from train; map unseen levels in eval/test to a fallback (e.g., the train mode).
- For grplasso/grpnet only: build a polynomial expansion of the numeric predictors (e.g., 3rd order) and one-hot encode factors; assign each numeric's polynomial terms to one block and each multi-level factor's dummies to another block.
- For glm/gam/tdboost: use the scaled raw features without polynomial expansion.
- **Adaptive k for GAM:** for each smooth predictor, set `k = min(10, n_unique_values - 1)` to avoid "fewer unique covariate combinations than maximum degrees of freedom" errors on low-cardinality variables.

This logic lives in `lib/data_loader.R` and is shared by all five procedures. The exact same logic must drive the predict-fn closures (Section 7.1).

**Note on `row_id`.** Treat it as an opaque token. Carry it through preprocessing untouched.

---

## 5. Gini index (M(x) ≡ 1)

The benchmark metric is the Gini index of the **ordered Lorenz curve** with constant baseline premium M(x) ≡ 1. If a knowledge wiki is present, it will likely contain a useful Gini concept page with implementation guidance; otherwise the agent implements `lib/gini.R` from first principles. Each procedure script computes `eval_gini` on its eval predictions and writes it to the trial CSV (Section 7). The agent does **not** compute test Gini — that is the orchestrator's job, via `score_dataset()` (Section 8), which scores the saved test predictions through the eval API.

---

## 6. Project structure

**Workspace folder naming.**

```
run-<harness>-<model>_<thinking>-<YYYYMMDD_HHMMSS>
```

where:
- `<harness>`: `claudecode`, `codex`, or `openclaw`
- `<model>`: e.g., `sonnet46`, `gpt4o`, `opus47`
- `<thinking>`: `high`, `medium`, or `low` — read from the `THINKING_LEVEL` environment variable if set. If not set and the agent is unsure, use `unknown` and proceed with the full benchmark immediately. After each dataset completes, ask the user once for the thinking level; keep asking after each subsequent dataset until a value is confirmed. Once confirmed, rename the workspace folder and all embedded paths replacing `unknown` with the confirmed value.
- `<YYYYMMDD_HHMMSS>`: wall-clock timestamp at folder-creation time

Results are nested by dataset:

```
run-<harness>-<model>_<thinking>-<timestamp>/
├── README.md
├── lib/
│   ├── data_loader.R
│   ├── gini.R
│   └── aggregate.R
├── procedures/
│   ├── 01_tweedie_glm.R
│   ├── 02_tweedie_gam.R
│   ├── 03_grplasso.R
│   ├── 04_grpnet.R
│   └── 05_tdboost.R
├── agent/
│   └── orchestrate.py
├── results/
│   ├── <dataset>/
│   │   ├── tweedie_glm/
│   │   │   ├── trials/trial_NN.csv
│   │   │   ├── predictions/trial_NN.json
│   │   │   ├── models/trial_NN.rds
│   │   │   ├── predict_fns/trial_NN.rds
│   │   │   └── trials.csv
│   │   ├── tweedie_gam/
│   │   ├── grplasso/
│   │   ├── grpnet/
│   │   ├── tdboost/
│   │   ├── grader_scores/
│   │   └── summary.csv
│   ├── summary.csv
│   └── history/
└── logs/
    ├── session_snapshot.jsonl     ← append-only snapshot (grows monotonically)
    └── r_subprocess/
        └── <dataset>_<model>_round<k>_<timestamp>.log
```

Each `trials/trial_NN.csv` contains: `trial, eval_gini, n_active, fit_time, status`.
Each `predictions/trial_NN.json` contains: `{model_id, row_ids, predictions}`.

### 6.1 Session log capture

The agent must capture its own harness session JSONL into `logs/` so the trajectory is auditable even if the run stops mid-way. One artifact only:

- **`logs/session_snapshot.jsonl`** — an append-only real file. After every trial, only new bytes from the live harness JSONL are appended to this file. It grows monotonically: never shrinks, never loses earlier content. Survives moving the workspace or deletion of the harness session file. There is **no** `session.jsonl` symlink — the snapshot is the single canonical capture artifact.

If the harness JSONL cannot be located, log a warning and proceed; do not halt.

#### 6.1.1 Pinning the live session JSONL (mandatory — DO NOT use mtime as the primary signal)

**The single largest correctness failure of this section is picking the wrong JSONL when multiple Claude Code / Codex / OpenClaw sessions are active in the same project directory at the same time. Newest-mtime "guessing" picks whichever session is *chattier*, which is almost never the one running the benchmark.** The orchestrator MUST therefore pin the target JSONL by the harness-exported session-id env var present in its own subprocess environment.

**Resolution order — try each in turn; stop at the first that produces a readable file:**

| # | Harness | Env var the orchestrator must read | JSONL path constructed from it |
|---|---|---|---|
| 1 | Claude Code | `CLAUDE_CODE_SESSION_ID` | `~/.claude/projects/<encoded-cwd>/<CLAUDE_CODE_SESSION_ID>.jsonl` |
| 2 | Codex | `CODEX_SESSION_ID` (and `CODEX_HOME`, default `~/.codex`) | `$CODEX_HOME/sessions/*/*/*/rollout-*<CODEX_SESSION_ID>*.jsonl` |
| 3 | OpenClaw | `OPENCLAW_SESSION_ID` (+ `OPENCLAW_AGENT_ID` if available) | `~/.openclaw/agents/<OPENCLAW_AGENT_ID>/sessions/<OPENCLAW_SESSION_ID>.jsonl` |
| 4 | Fallback (single-session only) | — | Newest-mtime `*.jsonl` in the per-harness project directory **only when none of the env vars in 1–3 are set**. The orchestrator MUST also emit a `WARN: no harness session env var set; falling back to newest-mtime — unreliable when multiple sessions exist` line so the choice is auditable. |

`<encoded-cwd>` is the orchestrator's working-directory path with `/` → `-` (Claude Code's convention). Search both the workspace-encoded path and its parent-encoded path, because the harness was usually started from the project root, not the workspace folder.

**Required behaviour:**

1. **Pin once at orchestrator start and re-validate the pin every refresh, but only via the env var — never re-pick by mtime.** Log the resolved path exactly once at startup: `session JSONL pinned to <path>`.
2. **Target-change guard.** Before appending bytes, compare the resolved target to the `active` field of `logs/.snapshot_offset.json`. If they differ, rename the existing `session_snapshot.jsonl` to `session_snapshot.<previous-target-basename>.jsonl` (preserving the contaminated history for audit) and start a fresh snapshot for the new target. This protects against stale offsets from a prior contaminated run.
3. **End-of-run contamination scan.** After the final dataset and grader pass, scan `session_snapshot.jsonl` for distinct `sessionId` values (the harness emits one per line). If more than one is found, write `logs/SNAPSHOT_CONTAMINATED.txt` listing every offending `sessionId` and the cause, and emit a `WARN:` to `orchestrator.log`. The benchmark still counts as complete, but the contamination is now loud rather than silent.

These three guards together ensure that even if the env-var lookup is somehow wrong, the contamination cannot stay hidden.

---

## 7. Procedure script contract

Each `procedures/0X_<model>.R`:

1. Takes CLI arg: `--trial <int>` (1 through 10).
2. Sets seed `1000 + trial` for reproducible fitting/CV behavior.
3. Reads `EVAL_API_URL_RESOLVED` and `EVAL_DATASET` from the environment.
4. GETs `train.csv` and `eval.csv` for the trial plus the global `test.csv`.
5. Preprocesses via `lib/data_loader.R` — fits scaler/imputer/factor-levels/polynomial-basis on **train** only, then applies to **eval** and **test**. Carries `row_id` through unchanged.
6. Fits on **train**, tunes on **eval** (early stopping for TDboost via `TDboost.perf`, λ selection for grplasso/grpnet via `cv.HDtweedie`, REML smoothing for GAM, no tuning for GLM).
7. Predicts on **eval**, computes `eval_gini` via `gini_insurance()`.
8. Predicts on **test**, saves `results/<dataset>/<model>/predictions/trial_<trial>.json` with `{model_id: "<model>_v1", row_ids: <test$row_id>, predictions: <test predictions>}`.
9. **Writes four artifacts on success**:
   - `trials/trial_<trial>.csv` with columns `trial, eval_gini, n_active, fit_time, status`.
   - `predictions/trial_<trial>.json` — test predictions.
   - `models/trial_<trial>.rds` — fitted model. For TDboost, `attr(fit, "best_iter") <- best_iter` before saving.
   - `predict_fns/trial_<trial>.rds` — self-contained predict closure (see §7.1).
   On caught error, writes only the trial CSV with `eval_gini=NA, status="ERROR: <message>"`.
10. Exits 0 on success, non-zero on uncaught failure.

### 7.1 Predict closure contract

Every procedure must build a closure that bundles preprocessing **and** the model into a single function:

```r
predict_fn <- function(new_raw_df) {
  # new_raw_df: data.frame with raw predictor columns (same names as test.csv, minus row_id)
  # returns: numeric vector of length nrow(new_raw_df), one predicted y per row.
}
```

Construction pattern:

```r
pre_state  <- list(scaler = scaler, imputer = imputer,
                   train_factor_levels = lapply(train_df[FAC], levels))
poly_state <- list(...)        # for grouped models only

predict_fn <- local({
  pre_state  <- pre_state
  poly_state <- poly_state
  fit        <- fit
  best_iter  <- if (exists("best_iter")) best_iter else NULL

  function(new_raw_df) {
    df <- apply_preprocessing(new_raw_df, pre_state)

    if (inherits(fit, "TDboost"))
      return(as.numeric(predict(fit, newdata = df, n.trees = best_iter, type = "response")))
    if (inherits(fit, c("gam", "glm")))
      return(as.numeric(predict(fit, newdata = df, type = "response")))

    x <- build_design_matrix(df, poly_state, pre_state$train_factor_levels)
    return(as.numeric(predict(fit, newx = x, s = "lambda.min", type = "response")))
  }
})

saveRDS(predict_fn, sprintf("results/%s/%s/predict_fns/trial_%02d.rds",
                            Sys.getenv("EVAL_DATASET"), MODEL, trial))
```

Two requirements:

1. **No external dependencies at predict time.** The closure must work in a fresh R session with only base R plus the model package. Must NOT call any agent function from `lib/data_loader.R`.
2. **Self-test before saving.** Call `predict_fn(test_df_raw)` and verify: correct length, no NAs/Infs, matches procedure's own test predictions within `1e-6`. If self-test fails, raise and write error-only trial CSV.

---

## 8. Orchestration — round-robin, sequential, fresh-each-run

The orchestrator lives at `agent/orchestrate.py` and is the single entry point for a run. The agent designs and writes the script; the plan only specifies the required behavior. Pick whatever Python style, libraries, and helper structure fit best.

**API URL resolution at startup.** Probe the eval API in order: explicit `EVAL_API_URL` env var → `http://localhost:8765` → `http://host.docker.internal:8765`. Use the first one whose `/healthz` endpoint answers within a short timeout (~2s). If none respond, halt with a clear error that lists what was tried.

**Dataset selection.** If `EVAL_DATASET` is set in the env, run only that dataset. Otherwise fetch the list from `GET /datasets`, order by the canonical priority (`autoclaim`, `fremtpl2`, `bemtpl97`, `ausprivauto`, `swautoins`, `sgautonb`), then append any extras the API returned in API-given order.

**Workspace preparation (every invocation).**
- Wipe `logs/` and recreate it, including a `r_subprocess/` subdirectory.
- Ensure `results/history/` exists.
- For each existing dataset directory under `results/`: keep it untouched if it is *fully complete* (all 5 models × 10 trials with `status == "OK"`); otherwise wipe it.
- Initialize the session log artifacts as described in §6.1.

**Execution loop.** For each dataset, in order:

1. For each round `k` in 1..10 (outer), for each of the 5 models (inner):
   - Skip the trial if `results/<dataset>/<model>/trials/trial_<NN>.csv` already exists with `status == "OK"`.
   - Otherwise create the per-model subdirectories (`trials/`, `predictions/`, `models/`, `predict_fns/`) and run `Rscript procedures/0X_<model>.R --trial <k>` in a subprocess with `EVAL_API_URL_RESOLVED` and `EVAL_DATASET` exported. Capture stdout+stderr to `logs/r_subprocess/<dataset>_<model>_round<k>_<timestamp>.log`.
   - If the subprocess produced no trial CSV, log a warning and continue.
   - After every trial (success or not): regenerate the summary (call `lib/aggregate.R::write_summary()`), copy `results/summary.csv` to `results/history/summary_<timestamp>.csv`, and append any new bytes from the live harness JSONL to `logs/session_snapshot.jsonl` — see §6.1.

2. After all 50 trials for the dataset complete, run the grader pass: for every saved `predictions/trial_<NN>.json`, POST its body to `/datasets/<dataset>/score/<NN>` with header `Authorization: Bearer test-token-12345` and `Content-Type: application/json`. Save the JSON response to `results/<dataset>/grader_scores/<model>_trial_<NN>.json`. Tolerate missing prediction files and per-trial scoring errors (log and continue). Regenerate the summary one more time so the test-Gini columns are populated.

3. After all datasets are done, print a clear completion line.

**Properties this guarantees.**
- Only one R subprocess runs at any moment — API quota is never split.
- `results/summary.csv` reflects the latest state after every trial; every intermediate state is archived in `results/history/`.
- Re-running cannot silently reuse stale partial work (incomplete datasets are wiped) but never destroys complete results.
- The session JSONL is captured continuously, not just at the end.

---

## 9. Aggregator — `lib/aggregate.R`

The aggregator lives at `lib/aggregate.R` and exposes one function — `write_summary()` — which the orchestrator calls after every trial and again after each dataset's grader pass. The agent writes the R code; the plan specifies the inputs, outputs, and rules.

**Inputs (per dataset, per model).**
- Per-trial CSVs at `results/<dataset>/<model>/trials/trial_<NN>.csv` with columns `trial, eval_gini, n_active, fit_time, status`.
- Per-trial grader scores at `results/<dataset>/grader_scores/<model>_trial_<NN>.json`. Each file holds either `{"value": <num>}` or `{"gini": <num>}` (accept both, in that order; missing or unparseable file → NA).

**Per-(dataset, model) row schema.**

| column | meaning |
|---|---|
| `dataset` | dataset name |
| `model` | one of the five model names |
| `n_completed` | total trial rows present (successes + errors) |
| `mean_eval_gini`, `sd_eval_gini` | agent-side stats, computed over successful trials only |
| `mean_test_gini`, `sd_test_gini` | grader-side stats, from the JSON scores |
| `success_rate` | `"X/10"` string |

A trial is **successful** iff `status == "OK"` AND `eval_gini` is non-NA. Use `NA` for any `sd_*` when fewer than 2 valid values are available. Use `NA` for any `mean_*` when there are zero valid values.

**Outputs (every call).**
- `results/<dataset>/<model>/trials.csv` — consolidated view of that model's per-trial CSVs (concatenated).
- `results/<dataset>/summary.csv` — 5 rows, one per model.
- `results/summary.csv` — top-level, rows = dataset × model, combining all datasets.

When walking dataset directories under `results/`, ignore the `history/` directory.

---

## 10. Final summary table format

Two levels: per-dataset `results/<dataset>/summary.csv` (5 rows, one per model) and the top-level `results/summary.csv` (rows = `dataset × model`). Columns:

| dataset | model | n_completed | mean_eval_gini | sd_eval_gini | mean_test_gini | sd_test_gini | success_rate |

`*_eval_gini` = agent-side values. `*_test_gini` = grader-side values from `score_dataset()`.

---

## 11. Trial success criterion

A trial counts as successful iff: `status == "OK"` AND `gini` is non-NA. Per-model success rate = (successful trials) / 10. Updated in `summary.csv` after every trial.

---

## 12. Pre-run verification checklist

**Philosophy.** The preflight is a *go/no-go* gate, not an audit. Halt **only** when the run literally cannot succeed. Log warnings for everything else and proceed.

### 12.1 Hard checks — halt if any fails

- **H1. Workspace is empty.** `results/` and `logs/` either do not exist or are empty.
- **H2. R packages are loadable.** `library(statmod); library(mgcv); library(HDtweedie); library(TDboost); library(cplm)` all succeed.
- **H3. Eval API is reachable.** Probe in order: `EVAL_API_URL`, `http://localhost:8765`, `http://host.docker.internal:8765`. `GET /datasets` must list at least one dataset; `GET /datasets/$EVAL_DATASET/info` must report `metric == "gini"`.
- **H4. Smoke fit succeeds end-to-end on trial 1 of the first dataset.** Fit Tweedie GLM on train/eval, compute non-NA Gini, call `predict_fn(test_df_raw)` and verify length + no NA/Inf.

### 12.2 Soft checks — warn and proceed

- Installed package signatures match any wiki documentation (if present); if not, adapt to the actual signature and log the discrepancy.
- `splits/test.csv` has `row_id` column and no response column.

### 12.3 After preflight — run end-to-end automatically

**Once all hard checks pass, execute the full benchmark without pausing or asking for confirmation:**

```bash
cd <workspace_root>
python agent/orchestrate.py
```

The agent's job is **not complete** until:
1. `results/summary.csv` exists with rows for every dataset, and
2. Every dataset's `summary.csv` has `mean_test_gini` populated.

Do not stop after code generation, smoke tests, or any intermediate milestone.

---

## 13. If a run fails

There is **no resume** within a dataset. If anything fails, re-run:

```bash
python agent/orchestrate.py
```

The orchestrator's skip logic (`status == OK` check in `run_trial()`) prevents re-running already-successful trials. Incomplete datasets are wiped and restarted. The eval API's split-generation salts persist across restarts, so splits are bit-identical.
