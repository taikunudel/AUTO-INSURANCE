# Auto Insurance Benchmark — Verification Checklist

## How to use this file

**Do not write or modify this checklist** unless the user explicitly asks for it.
Even when asked, confirm the proposed change with the user before editing.

**When using this checklist to audit an agent's behavior**, do not modify this
file. Output an answer that mirrors the checklist's structure exactly (same
phases, same items, same order) with a Verdict column appended. Fill in a check
mark for every item the run meets:

- ✅ — the point is met (read AND code follows, where both apply)
- 🆗 — acceptable: the wiki page was not read, but the code matches the
  recommendation anyway (treated as a soft pass; no further action needed)
- ❌ — the point is not met
- ❔ — cannot verify from artifacts alone (e.g. dialog-only items)

**Always print the full requirement text next to each `#`.** Do not output
audit tables with only the numeric identifier (e.g. `2B.4`) and a verdict —
nobody can read `1.7`, `2A.5`, `9.5` and remember what those mean. Every audit
row must include the human-readable requirement so the table stands on its own.

Do not invent new rows, drop existing ones, or reorder items.

---

Companion to [plan_v3.md](plan_v3.md). A complete enumeration of observable, verifiable requirements with checking methods. Use this as a go/no-go review of any run.

### Phase 0 — Workspace Setup & Isolation

| # | Requirement | How to verify |
|---|---|---|
| 0.1 | Workspace folder named `run-<harness>-<model>-<thinking>-<YYYYMMDD-HHMMSS>` — all lowercase, hyphens only, **no underscores**; `<harness>` ∈ {`claudecode`,`codex`,`openclaw`,`gemini`}; OpenRouter-served models carry an `or-` prefix on `<model>` (e.g. `or-gemini31pro`), direct/vLLM models do not | `basename $PWD` matches `^run-(claudecode\|codex\|openclaw\|gemini)-(or-)?[a-z0-9.-]+-[0-9]{8}-[0-9]{6}$` and contains no `_` |
| 0.2 | `<thinking>` = `unknown` if `THINKING_LEVEL` unset; renamed after user confirms | Transcript shows thinking-level question after each dataset until confirmed |
| 0.3 | Agent's working directory is INSIDE this folder for all work | `pwd` in early commands; all file paths relative |
| 0.4 | `results/` not pre-populated; all files have mtime ≥ run start | `find results/ -newer <run_start_marker>` matches all |
| 0.5 | All code in `lib/`, `procedures/`, `agent/` written fresh | File mtimes ≈ run start; no "copied from" comments |
| 0.6 | No reading of other workspace results/logs/fitted objects | Transcript grep: zero references to other workspaces |
| 0.7 | Never read/list/grep `do_not_read/` (always relative to the project folder) or any path inside it | Transcript grep: zero `cat`/`ls`/`find`/`grep`/`Read`/`Glob` calls referencing `do_not_read`; `find` over the folder shows no access timestamps from this run |
| 0.8 | `initial_prompt.md` written at workspace root, containing the verbatim first user prompt (in a fenced code block; multi-turn turns separated by `---`); not modified after creation | `cat initial_prompt.md` shows the prompt text; mtime matches workspace creation, not later |

### Phase 1 — Environment Discovery

| # | Requirement | How to verify |
|---|---|---|
| 1.1 | API URL probed in order: `EVAL_API_URL` → `localhost:8765` → `host.docker.internal:8765` | Read `orchestrate.py` `resolve_api_url()` |
| 1.2 | 2-second timeout on probes | Code: `timeout=2.0` in `probe()` |
| 1.3 | Halts with clear error if all probes fail | Code: `raise SystemExit(...)` |
| 1.4 | `GET /datasets` called; returns ≥1 dataset | Logs show `[api] resolved` and listing |
| 1.5 | `GET /datasets/<ds>/info` called; `metric == "gini"` confirmed | Transcript shows manifest fetch |
| 1.6 | Canonical order respected, then API extras appended | `orchestrate.py` `CANONICAL_ORDER` exact |
| 1.7 | If `EVAL_DATASET` set, only that runs | Code: `[os.environ["EVAL_DATASET"]] if ...` |
| 1.8 | No hardcoded predictor names | Grep code; uses `info$numeric_predictors` etc. |
| 1.9 | Agent does NOT read API source code | Transcript grep: zero reads of API server files |

### Phase 2 — Wiki Consultation & Code Generation

The wiki lives at `/Users/theo/Downloads/auto-insurance/llm-wiki-agent/knowledge/wiki/`.
Each item in this phase uses the three-state verdict described at the top of
this file: ✅ when the page was read and the code follows it, 🆗 when the page
was not read but the code matches the wiki's recommendation, ❌ otherwise.

#### Phase 2A — Per-model source consultation

For each of the 5 models the wiki has both a concept page and a runnable
example. At least one of the two must have been consulted, and the resulting
procedure must follow the wiki's conventions.

| # | Model | Concept page | Example file | How to verify |
|---|---|---|---|---|
| 2A.1 | 01 Tweedie GLM | `concepts/GeneralizedLinearModels.md` | `examples/smyth-jorgensen-2002-tweedie-dispersion.R` | Transcript shows ≥1 read; `procedures/01_tweedie_glm.R` uses `statmod::tweedie(var.power, link.power=0)` and `predict(type="response")` |
| 2A.2 | 02 Tweedie GAM | `concepts/GeneralizedAdditiveModels.md` | `examples/wood-2011-gam-reml.R` | Transcript shows ≥1 read; `procedures/02_tweedie_gam.R` uses `mgcv::Tweedie(p, link=power(0))`, `method="REML"`, `select=TRUE`, factors outside `s()` |
| 2A.3 | 03 GrpLasso | `concepts/GroupedElasticNet.md` | `examples/qian-2016-hdtweedie.R` | Transcript shows ≥1 read; `procedures/03_grplasso.R` uses HDtweedie (or equivalent) with `alpha=1.0` |
| 2A.4 | 04 GrpNet | `concepts/GroupedElasticNet.md` | `examples/qian-2016-hdtweedie.R` | Transcript shows ≥1 read; `procedures/04_grpnet.R` uses grouped elastic net with `alpha ∈ (0,1)` |
| 2A.5 | 05 TDboost | `concepts/GradientTreeBoosting.md` | `examples/yang-2016-tdboost.R` | Transcript shows ≥1 read; `procedures/05_tdboost.R` uses `distribution=list(name="EDM", alpha=p)` and picks `best_iter` from `TDboost.perf(method="cv")` |

#### Phase 2B — Cross-cutting concept pages

These pages apply across all 5 models and the evaluation pipeline.

| # | Concept page | Why critical | How to verify |
|---|---|---|---|
| 2B.1 | `concepts/TweedieDistribution.md` | Defines the response family; raw zeros must be preserved | Read evidence + `lib/data_loader.R` does not filter zeros |
| 2B.2 | `concepts/GiniIndex.md` | Ordered Lorenz, not classical Gini | Read evidence + `lib/gini.R` implements ordered Gini per Frees–Meyers–Cummings |
| 2B.3 | `concepts/LorenzCurve.md` | Ordering convention behind the Gini computation | Read evidence + Gini implementation respects the ordering |
| 2B.4 | `concepts/LeakageAudit.md` | Required protocol when any trial's gini exceeds 0.5 | Read evidence + code path (in orchestrator or aggregator) triggers an audit when threshold exceeded |
| 2B.5 | `concepts/TweedieVariancePowerEstimation.md` | Justifies (or critiques) hardcoded `p`; without it the agent cannot claim an informed decision | Read evidence + decision event cites it, OR a task-mandated override is explicitly documented in the procedure file's header comment |

#### Phase 2C — Package-specific pitfalls

Silent-failure modes the wiki explicitly warns about. Each item passes only if
the generated code honors the pitfall, whether or not the agent read the
documenting page.

| # | Pitfall | Where to check |
|---|---|---|
| 2C.1 | GLM `predict(type="response")`, not `"link"` | `procedures/01_tweedie_glm.R` |
| 2C.2 | GLM factor-level alignment train ↔ test (unseen levels handled deterministically) | `procedures/01_tweedie_glm.R` or `lib/data_loader.R` |
| 2C.3 | GAM: `mgcv::Tweedie(p, link=power(0))` — NOT `link.power=0` (that's the `statmod::tweedie` spelling) | `procedures/02_tweedie_gam.R` |
| 2C.4 | GAM: `method="REML"`, never the default `GCV.Cp` | `procedures/02_tweedie_gam.R` |
| 2C.5 | GAM: factor predictors enter directly, NOT inside `s()` | `procedures/02_tweedie_gam.R` |
| 2C.6 | HDtweedie design matrix built with `~ ... - 1` (no intercept column) | `procedures/03_grplasso.R`, `procedures/04_grpnet.R`, or `lib/data_loader.R::build_grouped_design` |
| 2C.7 | HDtweedie `predict(..., s = "lambda.min")` explicitly | `procedures/03_grplasso.R`, `procedures/04_grpnet.R` |
| 2C.8 | TDboost: predict at `best_iter` from `TDboost.perf(method="cv")`, NEVER at `fit$n.trees` | `procedures/05_tdboost.R` |

#### Phase 2D — Group-structure correctness

| # | Requirement | How to verify |
|---|---|---|
| 2D.1 | Group vector for HDtweedie: all dummies of one factor share ONE group; each numeric column is its own group. A naive `1:ncol(X)` defeats the method. | Inspect `lib/data_loader.R::build_grouped_design` (or wherever the group vector is built); confirm factor dummies are mapped to their parent factor name |

#### Phase 2F — Trajectory & citation faithfulness

Evidence-of-consultation requirements (separate from whether consultation
actually changed behavior).

| # | Requirement | How to verify |
|---|---|---|
| 2F.1 | Every `Read` of a `knowledge/wiki/**` file is mirrored by a `wiki_read` event in `audit/trajectories/<task-id>.jsonl` | Count of `wiki_read` events ≥ count of distinct wiki `Read` calls |
| 2F.2 | Every `[[Page]]` citation token in generated code corresponds to a page that was actually read | Grep `lib/` and `procedures/` for `[[...]]` tokens; cross-check against the set of wiki paths read |
| 2F.3 | Every substantive `decision` event has a non-empty `cites` array | Inspect trajectory; `cites: []` on a substantive decision is a faithfulness fail |

#### Phase 2G — Decision rationale

Where the task spec and the wiki disagree, the divergence must be explicitly
acknowledged.

| # | Decision | How to verify |
|---|---|---|
| 2G.1 | Hardcoded `p` (vs profiling): the dissenting view in `concepts/TweedieVariancePowerEstimation.md` is acknowledged | Either the trajectory has a `decision` event citing that page, OR the procedure files' headers explicitly note the task override |
| 2G.2 | Leakage audit triggered when any trial's gini exceeds 0.5 | `concepts/LeakageAudit.md` read AND the orchestrator/aggregator has a code path that fires the audit when the threshold is crossed |

### Phase 3 — Data Pipeline (`lib/data_loader.R`)

| # | Requirement | How to verify |
|---|---|---|
| 3.1 | Splits fetched via API URLs only (no raw files, no R-package datasets) | Grep `lib/data_loader.R` for the API URL pattern; no `load()`/`data()` calls |
| 3.2 | Train path: `/datasets/<ds>/splits/<k>/train.csv` | Code inspection |
| 3.3 | Eval path: `/datasets/<ds>/splits/<k>/eval.csv` | Code inspection |
| 3.4 | Test path: `/datasets/<ds>/splits/test.csv` (NO `<k>` segment — global) | Code inspection |
| 3.5 | Preprocessing state fitted on TRAIN only and reused on eval/test | Code shows state created from `train_df` and applied (not refit) to eval/test |
| 3.6 | Grouped design matrix produced for `grplasso`/`grpnet` only; not for `glm`/`gam`/`tdboost` | Procedures `03`/`04` build groups; `01`/`02`/`05` do not |
| 3.7 | `row_id` carried through preprocessing untouched | Spot-check: row_id present in input and output, identical values |

### Phase 4 — Model Implementations

| # | Requirement | How to verify |
|---|---|---|
| 4.1 | All 5 R packages loadable | Preflight `library()` succeeds |
| 4.2 | Tweedie power p = 1.7 used by every model | Grep all 5 procedures for `1.7` in family/distribution args |
| 4.3 | GLM: no tuning | `01_tweedie_glm.R` has no CV/tuning loops |
| 4.4 | Each model's predict closure produces non-NA, finite predictions on test | Run any saved closure on raw test rows; output is numeric and complete |

### Phase 5 — Procedure Script Contract

| # | Requirement | How to verify |
|---|---|---|
| 5.1 | Accepts `--trial <int>` CLI arg | Grep each procedure: `commandArgs` + `--trial` |
| 5.2 | `set.seed(1000 + trial)` called early | Grep all 5 |
| 5.3 | Reads `EVAL_API_URL_RESOLVED` (NOT `EVAL_API_URL`) | Grep |
| 5.4 | Reads `EVAL_DATASET` | Grep |
| 5.5 | Fits on train, tunes on eval | Code flow |
| 5.6 | Computes `eval_gini` (non-NA on success) | Open trial CSV; `eval_gini` is finite numeric |
| 5.7 | Test JSON: `{model_id, row_ids, predictions}` | Open one JSON |
| 5.8 | `model_id` = `"<model>_v1"` | JSON inspection |
| 5.9 | Success: 4 artifacts (CSV/JSON/RDS/RDS) | `find results/<ds>/<model>/ -name "trial_01.*"` returns 4 |
| 5.10 | Error: only CSV with `status="ERROR: <msg>"` | Verify error trials lack JSON/RDS |
| 5.11 | Exit 0 on success, non-zero on uncaught failure | `echo $?` after manual run |
| 5.12 | Procedure does NOT call `/score` | Grep: zero `/score` or admin token usage |

### Phase 6 — Predict Closure

| # | Requirement | How to verify |
|---|---|---|
| 6.1 | Closure captures every preprocessing/model/tuning piece of state it needs | Inspect a saved `.rds` — calling it on raw rows succeeds without sourcing any other file |
| 6.2 | Works in a fresh R session with only base R + the model package | `R --vanilla -e 'p <- readRDS(...); p(df)'` returns a numeric vector |
| 6.3 | Does NOT call any function from `lib/data_loader.R` | Grep closure body for `source(`/`data_loader` references |
| 6.4 | Self-test runs `predict_fn(test_df_raw)` before saving | Grep procedure |
| 6.5 | Self-test verifies correct length, no NA/Inf, matches procedure's own test predictions within `1e-6` | Code inspection |
| 6.6 | Self-test failure → procedure raises, writes error-only CSV, no closure saved | Code path |

### Phase 7 — Gini

| # | Requirement | How to verify |
|---|---|---|
| 7.1 | `lib/gini.R` exists and produces non-NA, numeric `eval_gini` | Open trial CSVs; `eval_gini` is finite |
| 7.2 | If any trial's `eval_gini` > 0.5: leakage audit triggered (consult wiki if present) | Transcript shows audit reference when threshold exceeded |

### Phase 8 — Orchestrator

| # | Requirement | How to verify |
|---|---|---|
| 8.1 | `logs/` wiped on every invocation, `logs/r_subprocess/` recreated | Pre-run `ls logs/` empty after orchestrator starts |
| 8.2 | `results/history/` exists after startup | `ls results/history/` |
| 8.3 | Complete datasets (5×10 = 50 OK trials) preserved; incomplete ones wiped | Re-run on partial workspace: complete dataset kept, partial wiped |
| 8.4 | Round-robin: all 5 models for round k before any model starts round k+1 | Log file timestamps show all 5 models for round 01 finish before round 02 begins |
| 8.5 | Trials with `status == OK` are skipped on re-run | Re-run after a successful trial; orchestrator reports `[SKIP]` or equivalent |
| 8.6 | Each trial subprocess sees env vars `EVAL_API_URL_RESOLVED` and `EVAL_DATASET` | Inspect R log; values used in the subprocess |
| 8.7 | After every trial, `results/summary.csv` regenerated and a timestamped copy appears in `results/history/` | `ls results/history/` count grows after each trial |
| 8.8 | After each dataset's 50 trials, grader pass runs and writes `results/<ds>/grader_scores/<model>_trial_<NN>.json` | File structure populated before next dataset starts |
| 8.9 | Score POST sends header `Authorization: Bearer test-token-12345` | Code/log inspection |
| 8.10 | Orchestrator prints a clear completion line at the end | Last stdout line indicates all datasets done |

### Phase 9 — Session Log Capture

| # | Requirement | How to verify |
|---|---|---|
| 9.1 | `logs/session_snapshot.jsonl` is a real file (no `session.jsonl` symlink exists) | `stat -f %HT logs/session_snapshot.jsonl` = `Regular File`; `test ! -e logs/session.jsonl` |
| 9.2 | Snapshot grows monotonically (append-only) | size(trial N+1) ≥ size(trial N) |
| 9.3 | Snapshot updated after every trial | `stat -f %m` ≈ last trial timestamp |
| 9.4 | Live harness JSONL pinned via env var (`CLAUDE_CODE_SESSION_ID` / `CODEX_SESSION_ID` / `OPENCLAW_SESSION_ID`), NEVER by newest-mtime as the primary signal | Code: `find_live_session_jsonl()` reads the env var first; mtime branch only after explicit `WARN` log line |
| 9.5 | Startup `orchestrator.log` line `session JSONL pinned to <path>` written exactly once | `grep "session JSONL pinned to" orchestrator.log` returns one line |
| 9.6 | Target-change guard: when the resolved JSONL differs from `.snapshot_offset.json`'s `active`, old snapshot renamed to `session_snapshot.<prev-sid>.jsonl` before a fresh one is started | Inspect code path; force a target change and confirm the rename |
| 9.7 | End-of-run contamination scan: snapshot scanned for distinct `sessionId` values; if >1, `logs/SNAPSHOT_CONTAMINATED.txt` written listing each offending id | `test -f logs/SNAPSHOT_CONTAMINATED.txt` only when contamination really happened |
| 9.8 | If harness JSONL not findable: warning logged, run proceeds | Transcript shows warning, not error |
| 9.9 | Snapshot contains all prior trial activity (no truncation) | `wc -l logs/session_snapshot.jsonl` grows across run |

### Phase 10 — Aggregator (`lib/aggregate.R`)

| # | Requirement | How to verify |
|---|---|---|
| 10.1 | `history/` not treated as a dataset when walking `results/` | Top-level `summary.csv` has no `history` row |
| 10.2 | Per-dataset `summary.csv` written (5 rows, one per model) | `ls results/<ds>/summary.csv`; row count = 5 |
| 10.3 | Top-level `results/summary.csv` written | Row count = N_datasets × 5 |
| 10.4 | Columns exact: `dataset, model, n_completed, mean_eval_gini, se_eval_gini, mean_test_gini, se_test_gini, success_rate` (SE = sd / √n_successful — standard error of the mean, not raw SD) | Open CSV, check header |
| 10.5 | Trial counted as "successful" iff `status == "OK"` AND `eval_gini` non-NA | Spot-check: a row with `status=ERROR` is NOT included in `mean_eval_gini` |
| 10.6 | `n_completed` includes both successes and errors | Compare per-trial CSV count to `n_completed` |
| 10.7 | `mean_eval_gini` computed over successful trials only | Manual mean of `eval_gini` from successful trial CSVs matches summary value |
| 10.8 | Grader test-Gini accepts `obj$value` or `obj$gini` (in that order); missing/unparseable → NA | Inspect aggregator; observe NA when grader file absent |
| 10.9 | `success_rate` format is `"X/10"` string | CSV inspection |
| 10.10 | `results/history/summary_<timestamp>.csv` accumulates one per regeneration | `ls results/history/` shows multiple files at end of run |
| 10.11 | Consolidated `trials.csv` produced per model | `ls results/<ds>/<model>/trials.csv` exists |

### Phase 11 — Preflight

| # | Requirement | How to verify |
|---|---|---|
| 11.1 | **H1:** `results/` and `logs/` empty/absent | Pre-run `ls` |
| 11.2 | **H2:** All 5 R packages load | Preflight log |
| 11.3 | **H3:** API reachable; target dataset metric == "gini" | Preflight log |
| 11.4 | **H4:** Smoke fit (GLM, trial 1) succeeds end-to-end | Preflight log |
| 11.5 | Soft checks logged as warnings, run proceeds | Warnings present, no halt |
| 11.6 | After preflight: run starts without pausing | No "ready to run, please confirm" |

### Phase 12 — Execution & Completion

| # | Requirement | How to verify |
|---|---|---|
| 12.1 | All datasets run to completion | Each `results/<ds>/summary.csv` exists |
| 12.2 | Each model: 10 trial CSVs | `find results/ -name "trial_*.csv" \| wc -l` ≥ 50 per dataset |
| 12.3 | `mean_test_gini` populated in every summary | CSV inspection |
| 12.4 | `results/summary.csv` exists with rows for every dataset | File check |
| 12.5 | Agent did NOT stop at intermediate milestone | Transcript review |

### Phase 13 — Behavioral Constraints

| # | Requirement | How to verify |
|---|---|---|
| 13.1 | Questions asked in bullet form, one per bullet, only when uncertain | Transcript |
| 13.2 | Agent did NOT request confirmation when plan specified action | Grep transcript |
| 13.3 | Agent did NOT summarize "about to do X" instead of doing X | Transcript |
| 13.4 | Agent did NOT treat preflight/smoke as deliverable | Run continued past |
| 13.5 | Only valid stops: H1–H4 failure, true uncertainty, unrecoverable error | Transcript review |

---

**A run that passes all of these is a clean, contamination-free benchmark execution.**
