# Auto Insurance Pricing Model Benchmark — Agent Execution Plan (v4)

> **What v4 is.** v4 keeps **v3's structure, output schema, and every design
> decision** (two measures only — Gini + success rate; **standard error**, not
> SD; `autoclaim` naming; body-shape API validation + LAN discovery;
> all-hyphen folder names; `initial_prompt.md` capture) so its results stay
> directly comparable to v3 runs and easy to analyze. On top of that skeleton
> it grafts **v1's copy-paste code** into every section and **v1's verification
> checklist** (Appendix A), so a weak agent can execute the whole benchmark by
> following the code literally. **Where v1 and v3 disagree, v3 wins.** v4 has
> **no token tracking** — it was deliberately removed in v3.

## Folder Naming — READ THIS FIRST (non-negotiable)

Every run lives in a workspace folder whose name follows this exact pattern —
**all lowercase, hyphens only, NO underscores anywhere**:

```
run-<harness>-<model>-<thinking>-<YYYYMMDD-HHMMSS>
```

- **`<harness>`** — the CLI you run under: `claudecode`, `codex`, `openclaw`, or `gemini`.
- **`<model>`** — a short id for the underlying model (e.g. `opus47`, `sonnet46`, `gpt5.4`, `gemini31pro`, `glm47`, `qwen35`).
  - **OpenRouter rule:** if your bootstrap prompt names the model like `openrouter/google/gemini-3.1-pro-preview`, the model is served through **OpenRouter** — prefix the token with **`or-`** → `or-gemini31pro`.
  - Models reached any other way — Google's Gemini API via the `gemini` harness, OpenAI, Anthropic, or a self-hosted **vLLM** endpoint — get **no** prefix.
- **`<thinking>`** — reasoning level: `low` / `medium` / `high` / `max` / `xhigh` / `extra-high` / `off` / … (hyphens, never spaces or underscores).
- **`<YYYYMMDD-HHMMSS>`** — wall-clock folder-creation time, date and time joined by a hyphen (e.g. `20260527-075515`). **No underscore.**

### Worked examples — copy the pattern

| Situation | Folder name |
|---|---|
| Claude Code · Opus 4.7 · max | `run-claudecode-opus47-max-20260527-075454` |
| Codex · GPT-5.4 · extra-high | `run-codex-gpt5.4-extra-high-20260526-101752` |
| Gemini CLI · Gemini 3.5 Flash (Google direct) | `run-gemini-gemini35flash-high-20260527-075533` |
| openclaw · Gemini 3.1 Pro **via OpenRouter** | `run-openclaw-or-gemini31pro-high-20260529-032103` |
| openclaw · GLM-4.7 **via OpenRouter** | `run-openclaw-or-glm47-high-20260528-172557` |
| openclaw · Qwen3.5-35B **via vLLM** (not OpenRouter) | `run-openclaw-qwen35-off-20260528-080707` |

**The same model from two sources gets two different names:** `gemini35flash`
(Google, under the `gemini` harness) vs `or-gemini35flash` (OpenRouter, under
e.g. openclaw). The `or-` prefix is the *only* thing that distinguishes the
source — get it right.

> **Note on underscores.** The no-underscore rule applies to the **workspace
> folder name** only. Underscores are fine as *field separators* inside
> filenames the scripts generate (e.g. `logs/r_subprocess/autoclaim_tdboost_round3_20260527-075515.log`)
> and inside model directory names (`tweedie_glm`, etc.).

---

## 0. No reuse of prior runs

This is a fresh-each-time benchmark. Every implementation run must:

- **Start from an empty workspace.** Do not copy code, scripts, models, predictions, fitted objects, or summary CSVs from any prior benchmark run, your own or anyone else's. The reference for what to build is this plan, not other people's results directories.
- **Not consult `archive/`, sibling project folders, or any path containing `auto-insurance-bench-*`.** If such directories exist on the filesystem, treat them as out of scope and do not read them.
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

**Reaching the eval API — local, Docker, or peer-on-LAN.** The agent never knows up-front whether it's inside a Docker container, directly on the host, or on a peer machine reaching the API over the LAN.

> ⚠️ **The single biggest time-waster in this section is treating "something answers on port 8765" as "the eval API answers on port 8765".** A different FastAPI service squatting on the same port will return a clean HTTP 200 (or a clean 404) for probes that check status codes alone. **Always validate the response body shape, not just the status code.** And when the standard probes fail, **exhaust LAN auto-discovery before halting** — the canonical multi-agent setup hosts the API on a peer machine whose hostname or IP the agent cannot guess from inside its own environment.

The required probe behavior is:

1. **`EVAL_API_URL`** if set in the environment — probe this URL first. If it validates (see below), use it and stop.
2. **`http://localhost:8765`** — probe and validate. Works outside Docker; also works inside Docker if launched with `--network host`.
3. **`http://host.docker.internal:8765`** — probe and validate. Works inside Docker Desktop on macOS/Windows.
4. **LAN auto-discovery** — perform this **only** when steps 1–3 all fail AND `EVAL_API_URL` was not set. Read the local ARP table (`arp -an` on macOS/Linux), and probe each non-multicast peer IP on port 8765 with the same validation as above. Stop at the first peer that validates. On success, emit a prominent line — `WARN: eval API auto-discovered at <url>; on the next run, set EVAL_API_URL=<url> to skip discovery` — so the human running the benchmark can pin it explicitly going forward. Discovery exists for first-contact and recovery; it is **not** the intended steady-state mode.
5. **Halt** with a clear error and the diagnostic ladder below — **only** after steps 1–4 have all failed.

**What "validate" means — this is the trip-wire; do not skip any of these checks:**

- `GET <url>/healthz` returns HTTP 200 with body `{"ok": true}`. A 200 with any other body (e.g. `{"status": "running"}` from a different service), or any non-200 status including a clean 404, **is not validation** — reject this URL and move to the next candidate.
- `GET <url>/datasets` returns HTTP 200 with a JSON **object** whose values look like dataset manifests (each has at least a `name` and a `metric` field). A `{"detail": "Not Found"}`, `{"error": ...}`, or an array payload means another service answered — reject and continue.
- Before fitting anything for a given dataset, `GET <url>/datasets/<ds>/info` must report `metric == "gini"`. If it does not, halt — this benchmark cannot interpret a different metric.

A URL that answers but fails any of these checks **must not be used**. An orchestrator that silently sends `/splits/<k>/train.csv` requests to a non-eval-API service will appear to "run" while producing garbage: the CSV fetch will 404, R will write error trial rows, every trial will fail with the same opaque message, and an entire dataset's worth of compute will be wasted before the operator notices. **Validate up-front.**

**Always prefer setting `EVAL_API_URL` explicitly when you know the URL** — whether you are on the same host, in a container, or on a LAN peer. Auto-discovery is a safety net, not a substitute for telling the agent where to look.

**Scenario matrix — how to point the agent at the API:**

- *Same machine, bare metal*: leave `EVAL_API_URL` unset; `localhost:8765` works automatically.
- *Same machine, Docker container*: leave `EVAL_API_URL` unset on Docker Desktop (`host.docker.internal:8765` resolves automatically). On Linux Docker (no Docker Desktop), `host.docker.internal` is not provisioned by default — either add `--add-host=host.docker.internal:host-gateway` to `docker run`, or set `EVAL_API_URL` to the host's LAN IP explicitly.
- *Different machine, same LAN* (common when one Mac hosts the API and grader while multiple agent machines run in parallel against it): the local-only probes (#2 and #3) **will fail**. Export `EVAL_API_URL` explicitly to one of:
  - `http://<hostname>.local:8765` when both machines support mDNS (macOS, Linux with avahi). If mDNS resolution is flaky during testing, pin it with `curl --resolve <hostname>.local:8765:<ip> http://<hostname>.local:8765/healthz`.
  - `http://<lan-ip>:8765` (e.g., `http://10.0.0.250:8765`) — most robust, no DNS dependency.

**Server-side prerequisites for LAN access** (the API host's responsibility, verified once during initial setup — not the agent's job, but the agent should know what a healthy host looks like so it can diagnose failures):

- The eval API must be bound to `0.0.0.0:8765` (or to a specific LAN interface), not `127.0.0.1:8765`. From the host, `lsof -iTCP:8765 -sTCP:LISTEN` should show `NAME` as `*:8765` or `<lan-ip>:8765` — never `localhost:8765` or `127.0.0.1:8765`.
- The host's firewall must not block inbound TCP on 8765 (macOS Application Firewall off, or with an explicit allow rule for the API process).

**Diagnostic ladder when the probe halts.** When `resolve_api_url()` exhausts all candidates, do not give up after a single failed probe. Work through these in order from the agent machine to localize the fault:

1. `ping <host>` — confirms the host is reachable on the network. ICMP succeeds → host is up; fails → Wi-Fi mismatch / VPN / wrong network. `.local`-style hostnames depend on mDNS; check resolution with `dscacheutil -q host -a name <host>.local` on macOS, or try the LAN IP directly.
2. `nc -zv <host> 8765` or `curl -m 3 http://<host>:8765/healthz` — distinguishes "no service" from "no host". **Connection refused** (fast, sub-second RST) means the host is up but nothing is listening on 8765 (service down, or bound to loopback only). **Timeout** (slow, multi-second) means a firewall is silently dropping packets.
3. On the API host: `lsof -iTCP:8765 -sTCP:LISTEN` confirms the API process and its binding (see prerequisites above). If the binding is wrong, rebind to `0.0.0.0:8765`.
4. macOS Application Firewall: off, or has an allow rule for the API process. System Settings → Network → Firewall.
5. On the agent: `netstat -rn | head` and `arp -a | grep <ip>` — confirm no VPN is routing LAN traffic out a `utun*` interface, and that the ARP entry isn't stale (flush with `sudo arp -d <ip>; ping -c 2 <ip>` if needed).

**Retry-once caveat.** A brief connection-refused window can happen when the host operator is restarting the API service (e.g., menu-bar app rebuild). Always retry once after a few seconds before invoking the full diagnostic ladder.

**Authentication.** `GET` endpoints (`/healthz`, `/datasets`, `/datasets/<n>/info`, `/splits/<k>/{train,eval}.csv`, `/splits/test.csv`) are open — no auth header required. `POST /datasets/<n>/score/<k>` requires header `Authorization: Bearer test-token-12345`. This is set by the orchestrator's grader pass (Section 8); the agent's procedure scripts never call `/score` directly.

Each model is run **10 times**. The eval API holds a **single global test set** (~20% of rows, sealed labels) carved out once at startup — every trial scores against the same test set. The remaining ~80% is re-split per trial into train (~70%) and eval (~10%). Execution is **round-robin and strictly sequential**: round 1 runs all 5 models on `(train_1, eval_1)`, then round 2, and so on.

The single-global-test design is deliberate: an earlier per-trial-test design let an agent recover trial 1's test labels by joining its predictor values to trial 2's train (each row was labeled in 8 of 10 trials). One global test that's *never* labeled in any trial closes that leak.

The agent saves test predictions as JSON files and the **grader** — who holds the API admin token — runs `POST /datasets/$EVAL_DATASET/score/<k>` afterward to compute the authoritative test Gini. The orchestrator runs this grader pass immediately after each dataset's 50 trials complete (Section 8), so `mean_test_gini` is populated before the agent moves to the next dataset.

---

## 2. The five models

**Tweedie GLM.** Generalized linear model with Tweedie compound Poisson family and log link. The mean function is strictly log-linear in the predictors. Rigid baseline — captures no nonlinearity or interactions unless features are manually engineered.

**Tweedie GAM.** Generalized additive model with Tweedie family. Each numerical predictor enters through a penalized smoothing spline; categorical predictors enter as factors. Captures arbitrary smooth main effects but interactions must be specified explicitly.

**GrpLasso.** Tweedie GLM with grouped lasso penalty. Predictors are partitioned into blocks (e.g., a categorical's dummy variables, or a numerical's polynomial expansion); the penalty selects or zeros out each block as a unit. Sparse, log-linear within retained blocks.

**GrpNet.** Tweedie GLM with grouped elastic net penalty. Same as GrpLasso but with an additional L2 component (mixing parameter τ < 1), which handles correlated blocks better and tends to retain more variables.

**TDboost.** Gradient tree-boosted Tweedie compound Poisson model. Fully nonparametric — learns the mean function as a sum of regression trees fit to the Tweedie deviance gradient. Captures arbitrary nonlinearities and high-order interactions automatically.

---

## 3. Models, packages, and usage

**Packages required:** `statmod` (GLM), `mgcv` (GAM), `HDtweedie` (GrpLasso/GrpNet), `TDboost`, `cplm` (Gini metric).

**Tweedie power: use p = 1.7 for all five models** (fixed, not estimated — consistent across models for comparability).

**If a knowledge wiki exists at `/Users/theo/Downloads/auto-insurance/knowledge/wiki/`, consult it before writing any model code** — it will likely contain useful concepts and code (calling conventions, common pitfalls, Tweedie-specific arguments, the Gini calculation, the leakage audit). Navigate it independently; there is no prescribed reading order. Cite the wiki page(s) that informed each modeling decision via `[[PageName]]` in code comments. Whether or not a wiki is present, adapt to whatever package signatures are installed and log any discrepancies — do not halt.

The code blocks below are **implementation sketches, not guaranteed-current APIs**. The agent **does** need to read the actual installed function signatures (`?HDtweedie::cv.HDtweedie`, etc.) before fitting, because installed packages may have evolved. Adapt to the real signature and log the discrepancy (Section 12.2).

### 3.1 Tweedie GLM — `statmod` package

```r
library(statmod)
# tweedie() provides the family object; fit with base glm()
fit <- glm(
  y ~ .,
  data        = train_df,
  family      = tweedie(var.power = 1.7, link.power = 0)  # link.power=0 means log link
)
y_pred <- predict(fit, newdata = test_df, type = "response")
```

### 3.2 Tweedie GAM — `mgcv` package

```r
library(mgcv)
# Wrap each numerical predictor in s() for spline smoothing; categoricals as factors.
# Use Tweedie(p=1.7) for fixed power (matches the other four models). tw() would estimate p.
fit <- gam(
  y ~ s(VehAge) + s(DrivAge) + s(BonusMalus) + s(VehPower) +
      VehBrand + VehGas + Region + Area,
  data   = train_df,
  family = Tweedie(p = 1.7, link = "log"),
  method = "REML"
)
y_pred <- predict(fit, newdata = test_df, type = "response")
```

The `s(...)` terms above are illustrative. **Build the formula programmatically**
from `info$numeric_predictors` (one `s()` per numeric) and `info$factor_predictors`
(bare factor terms) — do not hardcode column names. Guard each spline's basis
dimension: use `k = min(10, n_unique_values - 1)` so a low-cardinality numeric
does not trip mgcv's "fewer unique values than k" error.

### 3.3 GrpLasso — `HDtweedie` package

```r
library(HDtweedie)
# alpha=1 -> pure grouped lasso (tau=1 in paper notation)
# `group` is an integer vector mapping each column of x to a block ID
cv_fit <- cv.HDtweedie(
  x      = x_train,        # numeric matrix, with polynomial expansions etc.
  y      = y_train,
  group  = group_vec,      # e.g., c(1,1,1,2,2,2,3,4,5,5,...) — block assignments
  p      = 1.7,            # Tweedie power
  alpha  = 1,              # 1 = grouped lasso
  nfolds = 5
)
y_pred <- predict(cv_fit, newx = x_test, s = "lambda.min", type = "response")
```

### 3.4 GrpNet — `HDtweedie` package (same as GrpLasso, different alpha)

```r
library(HDtweedie)
# alpha=0.7 -> grouped elastic net (tau=0.7 in paper notation)
cv_fit <- cv.HDtweedie(
  x      = x_train,
  y      = y_train,
  group  = group_vec,
  p      = 1.7,
  alpha  = 0.7,            # 0.7 = grouped elastic net (< 1)
  nfolds = 5
)
y_pred <- predict(cv_fit, newx = x_test, s = "lambda.min", type = "response")
```

### 3.5 TDboost — `TDboost` package

```r
library(TDboost)
# distribution=list(name="EDM", alpha=1.7) -> here `alpha` means Tweedie power rho
# (NOT the elastic-net mixing parameter; package naming overloads with HDtweedie)
fit <- TDboost(
  y ~ .,
  data              = train_df,
  distribution      = list(name = "EDM", alpha = 1.7),
  n.trees           = 3000,
  shrinkage         = 0.005,
  interaction.depth = 5,
  cv.folds          = 5
)
best_iter <- TDboost.perf(fit, method = "cv")
y_pred <- predict(fit, newdata = test_df, n.trees = best_iter, type = "response")
```

### 3.6 Gini metric — `cplm` package

Use `cplm::gini()` for the ordered-Lorenz/Gini computation instead of maintaining a hand-written trapezoid implementation. It is the mature R implementation for insurance Gini and handles edge cases and asymptotic standard errors.

The agent uses this helper to score its own predictions on the **eval** split during the run. The grader uses the same computation (via the eval API's `/score` endpoint) to score test predictions afterward — both produce identical Gini numbers because the API computes Gini through the same `cplm::gini()` call.

```r
library(cplm)

gini_result <- cplm::gini(
  loss  = "y",
  score = "prediction",
  base  = "baseline",
  data  = data.frame(
    y          = y_test,
    prediction = as.numeric(y_pred),
    baseline   = 1
  )
)

# cplm stores Gini values in the S4 gini slot on a percent scale.
# Divide by 100 so result files keep the benchmark's 0..1 scale.
gini_value <- as.numeric(gini_result@gini[1, "prediction"]) / 100
```

### 3.7 Argument-name and object-structure traps the agent must verify

- `HDtweedie::cv.HDtweedie`: paper τ may be exposed as `alpha`. Read `?HDtweedie::cv.HDtweedie` once.
- `TDboost`: `distribution=list(name="EDM", alpha=...)` uses `alpha` for Tweedie power ρ — completely different meaning from HDtweedie's `alpha`.
- `mgcv`: use `Tweedie(p=1.7)` (fixed power), not `tw()` (estimates power). Use `method = "REML"`.
- `cplm::gini`: returns an S4 `"gini"` object; extract the package value from `object@gini[1, "prediction"]` and divide by 100 because cplm reports percent-scale Gini values.

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
# Resolve API URL by probing (Section 1): explicit env -> localhost ->
# host.docker.internal -> LAN. Orchestrator exports the validated URL.
api <- Sys.getenv("EVAL_API_URL_RESOLVED")
ds  <- Sys.getenv("EVAL_DATASET")
train_k <- read.csv(sprintf("%s/datasets/%s/splits/%d/train.csv", api, ds, k))
eval_k  <- read.csv(sprintf("%s/datasets/%s/splits/%d/eval.csv",  api, ds, k))
test_   <- read.csv(sprintf("%s/datasets/%s/splits/test.csv",     api, ds))   # global, no <k>
```

- `train` and `eval` carry the response column (named per `info$response_var`) plus all predictors plus an opaque `row_id` (token like `r_a8f9c2b1...`).
- `test` carries predictors and `row_id` only — **no response column**.

**Preprocessing — agent's call, fit on train only.** The plan does not prescribe specific transforms. After exploring the train side of trial 1, the agent decides what to apply, then **fits all preprocessing state on `train` only** and applies that state unchanged to `eval` and `test`. State includes scaling means/SDs, factor levels, NA imputers, polynomial bases, and any log/box-cox/winsorization the agent chose. Consult the wiki (if present) for model-specific preprocessing conventions and pitfalls; otherwise apply sensible defaults from first principles. Reasonable defaults to consider:

- Log-transform heavy-tailed non-negative numerics (e.g., monetary columns). Use `log1p`, not `log`, to tolerate zeros.
- Median-impute numeric NAs using **train** medians.
- Factor levels from **train**; map unseen levels in eval/test to a fallback (e.g., the train mode).
- For `grplasso`/`grpnet` only: build a polynomial expansion of the numeric predictors (e.g., 3rd order) and one-hot encode factors; assign each numeric's polynomial terms to **one block** and each multi-level factor's dummies to **one block** (`group` vector, NOT `1:ncol`).
- For `glm`/`gam`/`tdboost`: use the scaled raw features without polynomial expansion.

This logic lives in `lib/data_loader.R` and is shared by all five procedures so feature engineering cannot vary accidentally across models. The exact same logic must drive the predict-fn closures (Section 7.1).

**Note on `row_id`.** Treat it as an opaque token. Carry it through preprocessing untouched. When writing test predictions (Section 7), echo the test rows' `row_id` values back so the grader can match predictions to labels.

---

## 5. Gini index (M(x) ≡ 1)

The benchmark metric is the Gini index of the **ordered Lorenz curve** with constant baseline premium M(x) ≡ 1. If a knowledge wiki is present, it will likely contain a useful Gini concept page with implementation guidance; otherwise the agent implements `lib/gini.R` from the call below. Each procedure script computes `eval_gini` on its eval predictions and writes it to the trial CSV (Section 7). The agent does **not** compute test Gini — that is the orchestrator's job, via its grader pass (Section 8), which scores the saved test predictions through the eval API.

```r
# lib/gini.R
gini_insurance <- function(y_true, y_pred) {
  eval_df <- data.frame(
    y          = y_true,
    prediction = as.numeric(y_pred),
    baseline   = 1
  )

  g <- cplm::gini(
    loss  = "y",
    score = "prediction",
    base  = "baseline",
    data  = eval_df
  )

  as.numeric(g@gini[1, "prediction"]) / 100
}
```

Do not replace this with a custom Lorenz-curve implementation unless `cplm::gini()` cannot support the constant-baseline setup after verification.

**Where this gets called.** Each procedure script calls `gini_insurance()` on its **eval** predictions and reports that as the trial's `eval_gini` (Section 7). The test set has no `y` on the agent side, so the agent cannot compute test Gini — it saves test predictions to `results/<dataset>/<model>/predictions/trial_<NN>.json`, and the grader computes the authoritative test Gini afterward through the eval API.

> **Leakage audit.** If any eval Gini comes out > 0.5, treat it as a possible leak (a predictor echoing the response, a row_id ordering artifact, etc.). Re-check preprocessing and the train/eval/test boundary before trusting the number; consult the wiki's leakage-audit page if present.

---

## 6. Project structure

**Workspace folder naming.** Worked examples are in **Folder Naming — READ THIS FIRST** at the top of this plan. The pattern (all lowercase, hyphens only, **no underscores anywhere**):

```
run-<harness>-<model>-<thinking>-<YYYYMMDD-HHMMSS>
```

where:
- `<harness>`: `claudecode`, `codex`, `openclaw`, or `gemini`
- `<model>`: a short id for the model, e.g., `sonnet46`, `opus47`, `gpt5.4`, `gemini31pro`, `glm47`, `qwen35`. **If the model is served via OpenRouter** (the bootstrap prompt names it like `openrouter/...`), prefix the token with `or-` (e.g., `or-gemini31pro`, `or-glm47`). Models reached any other way — Google's Gemini API via the `gemini` harness, OpenAI, Anthropic, or a self-hosted vLLM endpoint — get no prefix.
- `<thinking>`: a short lowercase label for this run's thinking/reasoning level — read from the `THINKING_LEVEL` environment variable if set. Common values are `low`, `medium`, `high`, but the user may self-define any label they like (e.g., `extra-high`, `ultra`, `xhigh`). Use hyphens, never spaces or underscores. If `THINKING_LEVEL` is not set and the agent is unsure, use `unknown` and proceed with the full benchmark immediately. After each dataset completes, ask the user once for the thinking level; keep asking after each subsequent dataset until a value is confirmed. Once confirmed, rename the workspace folder and all embedded paths replacing `unknown` with the confirmed value.
- `<YYYYMMDD-HHMMSS>`: wall-clock timestamp at folder-creation time, date and time joined by a hyphen (no underscore)

Results are nested by dataset:

```
run-<harness>-<model>-<thinking>-<timestamp>/
├── README.md
├── initial_prompt.md           ← verbatim first user prompt that bootstrapped this run
├── lib/
│   ├── data_loader.R           # preprocessing module: takes (train, eval, test) frames fetched from the API
│   ├── gini.R                  # gini_insurance() backed by cplm::gini()
│   └── aggregate.R             # write_summary() — rebuilds per-dataset and top-level summaries
├── procedures/
│   ├── 01_tweedie_glm.R        # CLI: --trial <int>; reads EVAL_DATASET from env
│   ├── 02_tweedie_gam.R
│   ├── 03_grplasso.R
│   ├── 04_grpnet.R
│   └── 05_tdboost.R
├── agent/
│   └── orchestrate.py          # probes+validates API URL; loops datasets x rounds x models
├── results/
│   ├── <dataset>/              # e.g. autoclaim/, fremtpl2/, swautoins/, ...
│   │   ├── tweedie_glm/
│   │   │   ├── trials/trial_NN.csv         # one file per trial — atomic write
│   │   │   ├── predictions/trial_NN.json   # {model_id, row_ids, predictions} for the grader
│   │   │   ├── models/trial_NN.rds         # fitted model object
│   │   │   ├── predict_fns/trial_NN.rds    # self-contained predict closure (§7.1)
│   │   │   └── trials.csv                  # consolidated view, regenerated each round
│   │   ├── tweedie_gam/         # same substructure
│   │   ├── grplasso/            # same substructure
│   │   ├── grpnet/              # same substructure
│   │   ├── tdboost/             # same substructure
│   │   ├── grader_scores/       # populated by the grader pass; one JSON per (model, trial)
│   │   └── summary.csv          # per-dataset summary (5 rows, one per model), always current
│   ├── summary.csv             # top-level: rows = (dataset, model); aggregated from per-dataset summaries
│   └── history/
│       └── summary_<timestamp>.csv   # archived snapshots of the top-level summary
└── logs/
    ├── session_snapshot.jsonl  # append-only snapshot of live harness JSONL, grows monotonically
    └── r_subprocess/
        └── <dataset>_<model>_round<k>_<timestamp>.log
```

Splits are not stored on disk — they live behind the API.

Each `trials/trial_NN.csv` contains a single row: `trial, eval_gini, n_active, fit_time, status`. The `eval_gini` is the agent's self-reported Gini on the eval split (computed locally with `cplm::gini()`). Authoritative test Gini comes from `results/<dataset>/grader_scores/<model>_trial_NN.json` after the grader runs the scoring pass.
Each `predictions/trial_NN.json` contains `{model_id, row_ids, predictions}` for the test set, ready for the grader to POST to `/datasets/$EVAL_DATASET/score/<NN>`.
Each `models/trial_NN.rds` contains the fitted model object saved with `saveRDS()`. For GrpLasso and GrpNet the saved object is the `cv.HDtweedie` fit (which includes the full regularisation path). For TDboost the saved object is the `TDboost` fit with `attr(fit, "best_iter") <- best_iter` set before saving so the optimal iteration count travels with the object. Model files are written only on success.
Each `predict_fns/trial_NN.rds` contains a **self-contained predict closure** (§7.1).

**Why per-trial files in subfolders.** Storing each trial's result as its own file (`trial_01.csv`, `trial_02.csv`, …) instead of appending to a single CSV gives two benefits: writes are atomic per trial (no half-written rows on crash), and the consolidated `trials.csv` can always be regenerated by concatenating the per-trial files.

### 6.1 Initial prompt capture

At workspace creation, the agent writes the **verbatim first user prompt** that bootstrapped this run to `initial_prompt.md` at the workspace root. Write once, never modify after.

The first user prompt naturally encodes the run's settings — model, thinking level, dataset selection, any overrides — in whatever phrasing the user chose. Saving it verbatim is the only reliable record of how this run was configured when many parallel experiments use different prompts. Folder name + this file = "what did I ask the agent to do, this time".

Format: a markdown file with the prompt text inside a triple-backtick fence (no edits, no summarization). If the bootstrap was multi-turn, include each user turn separated by a `---` line. If the agent was invoked non-interactively with no user prompt (e.g., a cron job), write a short note explaining the trigger.

### 6.2 Session log capture

The agent must capture its own harness session JSONL into `logs/` so the trajectory is auditable even if the run stops mid-way. One artifact only:

- **`logs/session_snapshot.jsonl`** — an append-only real file. After every trial, only new bytes from the live harness JSONL are appended to this file. It grows monotonically: never shrinks, never loses earlier content. Survives moving the workspace or deletion of the harness session file. There is **no** `session.jsonl` symlink — the snapshot is the single canonical capture artifact.

If the harness JSONL cannot be located, log a warning and proceed; do not halt. The benchmark is the deliverable; the session log is supplementary auditability.

#### 6.2.1 Pinning the live session JSONL (mandatory — DO NOT use mtime as the primary signal)

**The single largest correctness failure of this section is picking the wrong JSONL when multiple Claude Code / Codex / OpenClaw sessions are active in the same project directory at the same time. Newest-mtime "guessing" picks whichever session is *chattier*, which is almost never the one running the benchmark.** The orchestrator MUST therefore pin the target JSONL by the harness-exported session-id env var that is present in its own subprocess environment.

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
3. **End-of-run contamination scan.** After the final dataset and grader pass, scan `session_snapshot.jsonl` for distinct `sessionId` values (the harness emits one per line). If more than one is found, write `logs/SNAPSHOT_CONTAMINATED.txt` listing every offending `sessionId` and the cause, and emit a `WARN:` to the orchestrator log. The benchmark still counts as complete, but the contamination is now loud rather than silent.

These three guards together ensure that even if the env-var lookup is somehow wrong, the contamination cannot stay hidden. Implementation lives in `agent/orchestrate.py` (Section 8) — see `discover_harness_session()`, `update_session_snapshot()`, and `contamination_scan()`.

---

## 7. Procedure script contract

Each `procedures/0X_<model>.R`:

1. Takes CLI arg: `--trial <int>` (1 through 10).
2. Sets seed `1000 + trial` for reproducible fitting/CV behavior.
3. Reads `EVAL_API_URL_RESOLVED` and `EVAL_DATASET` from the environment.
4. GETs `train.csv` and `eval.csv` for the trial from `/datasets/$EVAL_DATASET/splits/<trial>/`, plus the **global** `test.csv` from `/datasets/$EVAL_DATASET/splits/test.csv` (no `<trial>` segment for test).
5. Preprocesses via `lib/data_loader.R` (grouped variant for grplasso/grpnet, ungrouped for the other three) — fits scaler/imputer/factor-levels/polynomial-basis on **train** only, then applies that state to **eval** and **test**. Carries `row_id` through unchanged.
6. Fits on **train**, tunes on **eval** per the wiki's tuning guidance for each model (early stopping for TDboost via `TDboost.perf`, λ selection for grplasso/grpnet via `cv.HDtweedie`, REML smoothing for GAM, no tuning for GLM).
7. Predicts on **eval**, computes `eval_gini` via `gini_insurance()`.
8. Predicts on **test**, saves `results/<dataset>/<model>/predictions/trial_<trial>.json` with `{model_id: "<model>_v1", row_ids: <test$row_id>, predictions: <test predictions>}`. The agent does **not** call `/score` — it has no admin token.
9. **Writes four artifacts on success**:
   - `trials/trial_<trial>.csv` with columns `trial, eval_gini, n_active, fit_time, status`.
   - `predictions/trial_<trial>.json` — test predictions for the grader (step 8).
   - `models/trial_<trial>.rds` — the fitted model object saved with `saveRDS()`. For TDboost, `attr(fit, "best_iter") <- best_iter` is set before saving.
   - `predict_fns/trial_<trial>.rds` — a self-contained predict closure (§7.1). This is what the grader uses for any re-evaluation against a sealed test set.
   On caught error, writes only the trial CSV with `eval_gini=NA, status="ERROR: <message>"` (no predictions JSON, no model file, no predict closure).
10. Exits 0 on success, non-zero on uncaught failure.

The `n_active` column is the count of active (non-zero-coefficient / used) predictors where the concept applies — for grplasso/grpnet the number of non-zero blocks at `lambda.min`; for GLM/GAM the number of model terms; for TDboost it may be `NA` or the number of predictors with non-zero relative influence. Pick a sensible per-model definition; it is descriptive, not scored.

### 7.1 Predict closure contract

Every procedure must build a closure that bundles the trained preprocessing **and** the model into a single function with this signature:

```r
predict_fn <- function(new_raw_df) {
  # new_raw_df: data.frame with raw predictor columns (same names served by
  #             GET /datasets/$EVAL_DATASET/splits/test.csv, minus row_id).
  #             Any number of rows including 1.
  # returns: numeric vector of length nrow(new_raw_df), one predicted y per row.
}
```

Construction pattern (each procedure should follow this shape):

```r
# ---- inside the procedure script, after fit/tune/eval is done ----
# capture every piece of state the closure needs
pre_state  <- list(scaler = scaler, imputer = imputer,
                   train_factor_levels = lapply(train_df[FAC], levels))
poly_state <- list(...)        # for grouped models only

predict_fn <- local({
  # everything inside this local() is captured by reference; the closure
  # carries pre_state, poly_state, fit, best_iter (for TDboost), etc.
  pre_state  <- pre_state
  poly_state <- poly_state
  fit        <- fit
  best_iter  <- if (exists("best_iter")) best_iter else NULL

  function(new_raw_df) {
    # 1. align factor levels with train, impute, scale, log-transform — the
    #    EXACT same steps the procedure ran on its train side. Inline them or
    #    capture them here; do NOT call lib/data_loader.R.
    df <- apply_preprocessing(new_raw_df, pre_state)

    # 2a. for glm / gam / tdboost: predict from the data.frame
    if (inherits(fit, "TDboost"))
      return(as.numeric(predict(fit, newdata = df, n.trees = best_iter, type = "response")))
    if (inherits(fit, c("gam", "glm")))
      return(as.numeric(predict(fit, newdata = df, type = "response")))

    # 2b. for cv.HDtweedie / grouped: build the same x matrix the model was
    #     trained on (poly basis from poly_state, dummy encoding from train levels)
    x <- build_design_matrix(df, poly_state, pre_state$train_factor_levels)
    return(as.numeric(predict(fit, newx = x, s = "lambda.min", type = "response")))
  }
})

saveRDS(predict_fn, sprintf("results/%s/%s/predict_fns/trial_%02d.rds", DATASET, MODEL, trial))
```

Two requirements:

1. **No external dependencies at predict time.** The closure must work in a fresh R session with only base R plus whatever model package the `fit` object needs (`statmod`, `mgcv`, `HDtweedie`, `TDboost`). It must capture every piece of preprocessing state it needs (scalers, imputers, factor levels, polynomial basis, the fitted model itself, any tuning state) inside its environment, and must NOT call any agent function from `lib/data_loader.R` — inline the transforms or capture them in `local({...})`.
2. **Self-test before saving.** Each procedure must call `predict_fn(test_df_raw)` once on the raw test rows it just downloaded and verify the returned vector has length `nrow(test_df_raw)`, no `NA`s, no `Inf`s, and matches its own predicted-on-test values within `1e-6`. If the self-test fails, the procedure raises, falls through to the error branch, and writes only the error-only trial CSV.

The orchestrator treats the R scripts as black boxes that satisfy this contract.

---

## 8. Orchestration — round-robin, sequential, fresh-each-run

The orchestrator lives at `agent/orchestrate.py` and is the single entry point for a run. The behavior below is required; the code is a complete, working reference implementation that satisfies it. Adapt style as needed but preserve every guarantee.

```python
# agent/orchestrate.py
import os
import re
import csv
import json
import shutil
import socket
import ipaddress
import subprocess
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path

MODELS = ["tweedie_glm", "tweedie_gam", "grplasso", "grpnet", "tdboost"]
SCRIPTS = {m: f"procedures/0{i+1}_{m}.R" for i, m in enumerate(MODELS)}
N_ROUNDS = 10
ADMIN_TOKEN = "test-token-12345"

# Canonical priority order (Section 1). Most-cited datasets run first so a
# truncated run still produces results for the most-referenced benchmarks.
CANONICAL_ORDER = [
    "autoclaim",    # AutoClaim (10 papers)
    "fremtpl2",     # French MTPL (11 papers)
    "bemtpl97",     # Belgian MTPL 1997 (5 papers)
    "ausprivauto",  # Australian 2004-05 (3 papers)
    "swautoins",    # Swedish (2 papers)
    "sgautonb",     # Singapore (2 papers)
]

SNAP   = Path("logs/session_snapshot.jsonl")
OFFSET = Path("logs/.snapshot_offset.json")

# ---- API resolution: VALIDATE THE BODY, not just the status code ----------
def _get_json(url, timeout=2.5):
    try:
        with urllib.request.urlopen(url, timeout=timeout) as r:
            if r.status != 200:
                return None
            return json.loads(r.read().decode())
    except Exception:
        return None

def validate_api(base):
    """Section 1 trip-wire: body-shape validation. A different service on the
    same port returns clean 200s, so status alone is not enough."""
    h = _get_json(f"{base}/healthz")
    if not (isinstance(h, dict) and h.get("ok") is True):
        return False
    d = _get_json(f"{base}/datasets")
    if not (isinstance(d, dict) and d):
        return False
    # every value must look like a dataset manifest (name + metric)
    return all(isinstance(v, dict) and "name" in v and "metric" in v
               for v in d.values())

def arp_peers():
    """Non-multicast, non-loopback peer IPs from the local ARP table."""
    try:
        out = subprocess.run(["arp", "-an"], capture_output=True,
                             text=True, timeout=5).stdout
    except Exception:
        return []
    seen, peers = set(), []
    for m in re.finditer(r"\((\d+\.\d+\.\d+\.\d+)\)", out):
        ip = m.group(1)
        try:
            addr = ipaddress.ip_address(ip)
        except ValueError:
            continue
        if addr.is_multicast or addr.is_loopback or ip.endswith(".255"):
            continue
        if ip not in seen:
            seen.add(ip)
            peers.append(ip)
    return peers

def resolve_api_url():
    explicit = os.environ.get("EVAL_API_URL")
    candidates = [c for c in (explicit, "http://localhost:8765",
                              "http://host.docker.internal:8765") if c]
    for url in candidates:
        if validate_api(url):
            print(f"[api] resolved {url}")
            return url
    # LAN auto-discovery ONLY when explicit was not set and 1-3 all failed
    if not explicit:
        for ip in arp_peers():
            url = f"http://{ip}:8765"
            if validate_api(url):
                print(f"WARN: eval API auto-discovered at {url}; on the next "
                      f"run, set EVAL_API_URL={url} to skip discovery")
                return url
    raise SystemExit(
        f"[api] no validated eval API; tried {candidates} + ARP peers. "
        f"See the diagnostic ladder in Section 1.")

API_URL = resolve_api_url()

# ---- Resolve datasets to run ---------------------------------------------
def list_datasets():
    d = _get_json(f"{API_URL}/datasets") or {}
    api_names = list(d.keys())
    ordered = [x for x in CANONICAL_ORDER if x in api_names]
    extras  = [x for x in api_names if x not in CANONICAL_ORDER]
    return ordered + extras

if os.environ.get("EVAL_DATASET"):
    DATASETS = [os.environ["EVAL_DATASET"]]   # user pinned to one
else:
    DATASETS = list_datasets()                # canonical order, sequentially
print(f"[run] datasets: {DATASETS}")

# ---- Completeness check: 50/50 OK trials ---------------------------------
def _dataset_complete(dataset: str) -> bool:
    root = Path("results") / dataset
    if not root.exists():
        return False
    for m in MODELS:
        for k in range(1, N_ROUNDS + 1):
            p = root / m / "trials" / f"trial_{k:02d}.csv"
            if not p.exists():
                return False
            try:
                rows = list(csv.DictReader(p.open()))
                if not rows or rows[0].get("status") != "OK":
                    return False
            except Exception:
                return False
    return True

# ---- Session JSONL pinning + append-only snapshot (Section 6.2.1) --------
def discover_harness_session():
    """Pin THIS run's harness JSONL by env var. Mtime is forbidden as the
    primary signal — it picks the chattier session, not ours."""
    sid = os.environ.get("CLAUDE_CODE_SESSION_ID", "").strip()
    if sid:
        enc_here   = str(Path.cwd()).replace("/", "-")
        enc_parent = str(Path.cwd().parent).replace("/", "-")
        for enc in (enc_here, enc_parent):
            p = Path.home() / ".claude/projects" / enc / f"{sid}.jsonl"
            if p.exists():
                return str(p)
        print(f"[warn] CLAUDE_CODE_SESSION_ID={sid} set but no matching JSONL")

    codex_sid = os.environ.get("CODEX_SESSION_ID", "").strip()
    codex_home = Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))
    if codex_sid and codex_home.is_dir():
        matches = list(codex_home.glob(f"sessions/*/*/*/rollout-*{codex_sid}*.jsonl"))
        if matches:
            return str(sorted(matches, key=lambda p: p.stat().st_mtime, reverse=True)[0])

    oc_sid = os.environ.get("OPENCLAW_SESSION_ID", "").strip()
    oc_aid = os.environ.get("OPENCLAW_AGENT_ID", "").strip()
    if oc_sid:
        oc_root = Path.home() / ".openclaw" / "agents"
        if oc_aid:
            p = oc_root / oc_aid / "sessions" / f"{oc_sid}.jsonl"
            if p.exists():
                return str(p)
        matches = list(oc_root.glob(f"*/sessions/{oc_sid}.jsonl"))
        if matches:
            return str(matches[0])

    # Last-resort mtime fallback — single-session case only. Loud warning.
    harness = os.environ.get("AGENT_HARNESS", "claudecode")
    if harness == "claudecode":
        enc = str(Path.cwd()).replace("/", "-").lstrip("-")
        d = Path.home() / ".claude/projects" / f"-{enc}"
        files = sorted(d.glob("*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True)
        if files:
            print("WARN: no harness session env var set; falling back to "
                  f"newest-mtime ({files[0].name}) — unreliable when multiple "
                  "sessions exist")
            return str(files[0])
    return None

def pin_and_log_session():
    target = discover_harness_session()
    if target:
        print(f"session JSONL pinned to {target}")
    return target

def update_session_snapshot():
    """Append-only: extend SNAP with new bytes from the pinned live JSONL.
    Implements the target-change guard (Section 6.2.1 #2)."""
    target = discover_harness_session()
    if not target:
        return
    live = Path(target)
    if not live.exists():
        return
    prev = None
    if OFFSET.exists():
        try:
            prev = json.loads(OFFSET.read_text()).get("active")
        except Exception:
            prev = None
    if prev and prev != target and SNAP.exists():
        SNAP.rename(Path(f"logs/session_snapshot.{Path(prev).name}.jsonl"))
    try:
        live_size = live.stat().st_size
        snap_size = SNAP.stat().st_size if SNAP.exists() else 0
        if live_size > snap_size:
            with open(live, "rb") as src, open(SNAP, "ab") as dst:
                src.seek(snap_size)
                dst.write(src.read())
    except OSError:
        pass  # tolerate transient race during harness write
    try:
        OFFSET.write_text(json.dumps({"active": target}))
    except OSError:
        pass

def contamination_scan():
    """End-of-run: >1 distinct sessionId in the snapshot => loud failure file."""
    if not SNAP.exists():
        return
    sids = set()
    try:
        for line in SNAP.open():
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except Exception:
                continue
            sid = obj.get("sessionId")
            if sid:
                sids.add(sid)
    except OSError:
        return
    if len(sids) > 1:
        Path("logs/SNAPSHOT_CONTAMINATED.txt").write_text(
            "Multiple sessionId values in snapshot (cause: env-var pin "
            "resolved to >1 session across the run):\n" +
            "\n".join(sorted(sids)) + "\n")
        print("WARN: session snapshot contaminated — see "
              "logs/SNAPSHOT_CONTAMINATED.txt")

# ---- Workspace preparation (every invocation) ----------------------------
if Path("logs").exists():
    shutil.rmtree("logs")
Path("logs/r_subprocess").mkdir(parents=True, exist_ok=True)
Path("results/history").mkdir(parents=True, exist_ok=True)
pin_and_log_session()
update_session_snapshot()    # initial copy from the pinned live JSONL
if Path("results").exists():
    for child in Path("results").iterdir():
        if not child.is_dir() or child.name == "history":
            continue
        if _dataset_complete(child.name):
            print(f"[run] preserving complete dataset: {child.name}")
        else:
            print(f"[run] wiping unfinished dataset: {child.name}")
            shutil.rmtree(child)

def update_summary_and_archive():
    """Rebuild per-dataset and top-level summary.csv; archive a timestamped copy."""
    subprocess.run(["Rscript", "-e", "source('lib/aggregate.R'); write_summary()"],
                   check=True)
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    if Path("results/summary.csv").exists():
        shutil.copy("results/summary.csv", f"results/history/summary_{ts}.csv")

def run_trial(dataset: str, model: str, trial: int):
    """Run one (dataset, model, trial). Skip if already status==OK."""
    base = Path(f"results/{dataset}/{model}")
    trial_file = base / "trials" / f"trial_{trial:02d}.csv"
    if trial_file.exists():
        try:
            rows = list(csv.DictReader(trial_file.open()))
            if rows and rows[0].get("status") == "OK":
                print(f"[SKIP] {dataset}/{model} round {trial}: already OK")
                return
        except Exception:
            pass

    print(f"[RUN ] {dataset} / {model} round {trial}")
    for sub in ("trials", "predictions", "models", "predict_fns"):
        (base / sub).mkdir(parents=True, exist_ok=True)

    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    log_path = f"logs/r_subprocess/{dataset}_{model}_round{trial}_{ts}.log"
    env = {**os.environ,
           "EVAL_API_URL_RESOLVED": API_URL,
           "EVAL_DATASET":          dataset}
    with open(log_path, "w") as log:
        result = subprocess.run(["Rscript", SCRIPTS[model], "--trial", str(trial)],
                                stdout=log, stderr=subprocess.STDOUT, env=env)

    if not trial_file.exists():
        print(f"[WARN] {dataset}/{model} round {trial} produced no trial file "
              f"(rc={result.returncode})")

    update_summary_and_archive()
    update_session_snapshot()

def score_dataset(dataset: str):
    """After all 50 trials, POST every prediction JSON to /score and write the
    returned test Gini into results/<ds>/grader_scores/<model>_trial_NN.json."""
    gdir = Path(f"results/{dataset}/grader_scores")
    gdir.mkdir(parents=True, exist_ok=True)
    for model in MODELS:
        for trial in range(1, N_ROUNDS + 1):
            pred = Path(f"results/{dataset}/{model}/predictions/trial_{trial:02d}.json")
            if not pred.exists():
                print(f"[score SKIP] {dataset}/{model} trial {trial:02d}: no predictions")
                continue
            out = gdir / f"{model}_trial_{trial:02d}.json"
            try:
                req = urllib.request.Request(
                    f"{API_URL}/datasets/{dataset}/score/{trial}",
                    data=pred.read_bytes(),
                    headers={"Content-Type": "application/json",
                             "Authorization": f"Bearer {ADMIN_TOKEN}"},
                    method="POST")
                with urllib.request.urlopen(req, timeout=30) as r:
                    result = json.loads(r.read().decode())
                out.write_text(json.dumps(result))
                g = result.get("value", result.get("gini", "N/A"))
                print(f"[score OK ] {dataset}/{model} trial {trial:02d}: gini={g}")
            except Exception as e:
                print(f"[score ERR] {dataset}/{model} trial {trial:02d}: {e}")
    update_summary_and_archive()   # populate mean_test_gini / se_test_gini

# ---- Main loop: dataset (outer) -> round (mid) -> model (inner) -----------
for dataset in DATASETS:
    print(f"\n=== Dataset: {dataset} ===")
    for round_num in range(1, N_ROUNDS + 1):
        for model in MODELS:
            run_trial(dataset, model, round_num)
    print(f"\n[score] Scoring test predictions for {dataset} ...")
    score_dataset(dataset)

contamination_scan()
print("\nAll datasets complete.")
```

**Properties this guarantees.**
- Only one R subprocess runs at any moment — API quota is never split.
- The API URL is **validated by response-body shape**, not just status code, and LAN-discovered when local probes fail and no explicit URL was given.
- `results/summary.csv` reflects the latest state after every trial; every intermediate state is archived in `results/history/`.
- Re-running cannot silently reuse stale partial work (incomplete datasets are wiped, and the per-trial skip only re-uses `status==OK` rows) but never destroys complete results.
- The session JSONL is captured continuously, pinned by env var, with target-change and contamination guards.

---

## 9. Aggregator — `lib/aggregate.R`

The aggregator exposes one function — `write_summary()` — which the orchestrator calls after every trial and again after each dataset's grader pass. It reports **standard error of the mean** (`se = sd / sqrt(n_successful)`), *not* the standard deviation across seeds: SE quantifies uncertainty in the estimated mean and is the correct unit for cross-method comparisons.

**Inputs (per dataset, per model).**
- Per-trial CSVs at `results/<dataset>/<model>/trials/trial_<NN>.csv` with columns `trial, eval_gini, n_active, fit_time, status`.
- Per-trial grader scores at `results/<dataset>/grader_scores/<model>_trial_<NN>.json`. Each file holds either `{"value": <num>}` or `{"gini": <num>}` (accept both, **value first, then gini**; missing or unparseable → NA).

```r
# lib/aggregate.R — produces results/<dataset>/summary.csv per dataset, plus
# results/summary.csv combining all datasets (rows keyed by dataset + model).
write_summary <- function() {
  models <- c("tweedie_glm", "tweedie_gam", "grplasso", "grpnet", "tdboost")
  if (!dir.exists("results")) return(invisible(NULL))
  dataset_dirs <- setdiff(list.dirs("results", recursive = FALSE, full.names = FALSE),
                          c("history"))

  # Standard error of the mean; NA when fewer than 2 valid values.
  se <- function(x) if (length(x) > 1) sd(x) / sqrt(length(x)) else NA_real_

  # Grader score: accept {"value":...} first, then {"gini":...}, else NA.
  read_test_gini <- function(path) {
    if (!file.exists(path)) return(NA_real_)
    obj <- tryCatch(jsonlite::fromJSON(path), error = function(e) NULL)
    if (is.null(obj)) return(NA_real_)
    if (!is.null(obj$value)) return(as.numeric(obj$value))
    if (!is.null(obj$gini))  return(as.numeric(obj$gini))
    NA_real_
  }

  one_row <- function(dataset, model) {
    base       <- file.path("results", dataset, model)
    trials_dir <- file.path(base, "trials")
    empty <- data.frame(dataset = dataset, model = model, n_completed = 0L,
                        mean_eval_gini = NA_real_, se_eval_gini = NA_real_,
                        mean_test_gini = NA_real_, se_test_gini = NA_real_,
                        success_rate = "0/10", stringsAsFactors = FALSE)
    if (!dir.exists(trials_dir)) return(empty)
    trial_files <- list.files(trials_dir, pattern = "^trial_\\d+\\.csv$", full.names = TRUE)
    if (length(trial_files) == 0L) return(empty)
    trials <- do.call(rbind, lapply(trial_files, read.csv, stringsAsFactors = FALSE))
    write.csv(trials, file.path(base, "trials.csv"), row.names = FALSE)

    trials$success <- trials$status == "OK" & !is.na(trials$eval_gini)
    ok <- trials[trials$success, , drop = FALSE]

    grader_dir <- file.path("results", dataset, "grader_scores")
    test_ginis <- vapply(ok$trial, function(k)
      read_test_gini(file.path(grader_dir, sprintf("%s_trial_%02d.json", model, k))),
      numeric(1))
    test_ok <- test_ginis[!is.na(test_ginis)]

    data.frame(
      dataset        = dataset, model = model,
      n_completed    = nrow(trials),
      mean_eval_gini = if (nrow(ok) > 0)         mean(ok$eval_gini) else NA_real_,
      se_eval_gini   = se(ok$eval_gini),
      mean_test_gini = if (length(test_ok) > 0)  mean(test_ok)      else NA_real_,
      se_test_gini   = se(test_ok),
      success_rate   = sprintf("%d/10", sum(trials$success)),
      stringsAsFactors = FALSE
    )
  }

  top_rows <- list()
  for (d in dataset_dirs) {
    per_ds <- do.call(rbind, lapply(models, function(m) one_row(d, m)))
    # Per-dataset file omits the `dataset` column (implied by the path).
    write.csv(per_ds[, setdiff(names(per_ds), "dataset")],
              file.path("results", d, "summary.csv"), row.names = FALSE)
    top_rows[[d]] <- per_ds
  }
  combined <- do.call(rbind, top_rows)
  write.csv(combined, "results/summary.csv", row.names = FALSE)
}
```

**Per-(dataset, model) row schema.**

| column | meaning |
|---|---|
| `dataset` | dataset name (top-level file only) |
| `model` | one of the five model names |
| `n_completed` | total trial rows present (successes + errors) |
| `mean_eval_gini`, `se_eval_gini` | agent-side stats, over successful trials only |
| `mean_test_gini`, `se_test_gini` | grader-side stats, from the JSON scores |
| `success_rate` | `"X/10"` string |

A trial is **successful** iff `status == "OK"` AND `eval_gini` is non-NA. Use `NA` for any `se_*` when fewer than 2 valid values are available, and `NA` for any `mean_*` when there are zero valid values. When walking dataset directories under `results/`, ignore `history/`.

---

## 10. Final summary table format

Two levels: per-dataset `results/<dataset>/summary.csv` (5 rows, one per model) and the top-level `results/summary.csv` (rows = `dataset × model`). Columns:

| dataset | model | n_completed | mean_eval_gini | se_eval_gini | mean_test_gini | se_test_gini | success_rate |
|---|---|---|---|---|---|---|---|
| autoclaim | tweedie_glm | 10 | 0.xxx | 0.xxx | 0.xxx | 0.xxx | x/10 |
| autoclaim | tweedie_gam | 10 | 0.xxx | 0.xxx | 0.xxx | 0.xxx | x/10 |
| … | … | … | … | … | … | … | … |
| fremtpl2 | tweedie_glm | 10 | 0.xxx | 0.xxx | 0.xxx | 0.xxx | x/10 |
| … | … | … | … | … | … | … | … |

Per-dataset files omit the `dataset` column (it's implied by the path).

`*_eval_gini` = agent-side values, computed during the run from each procedure's eval predictions. `*_test_gini` = grader-side values from the orchestrator's grader pass (Section 8). `se_*` is the **standard error of the mean** across successful trials (`sd / sqrt(n_successful)`), not the raw standard deviation across seeds — it is the right unit for comparing methods. There are **no token columns** — token tracking is not part of this benchmark.

---

## 11. Trial success criterion

A trial counts as successful iff: `status == "OK"` AND `gini` is non-NA. Per-model success rate = (successful trials) / 10. Updated in `summary.csv` after every trial.

---

## 12. Pre-run verification checklist

**Philosophy.** The preflight is a *go/no-go* gate, not an audit. Halt **only** when the run literally cannot succeed. Log warnings for everything else and proceed. Do not invent extra paranoia checks (e.g., CRAN reachability) that were not asked for.

### 12.1 Hard checks — halt if any fails

- **H1. Workspace is empty.** `results/` and `logs/` either do not exist or are empty.
- **H2. R packages are loadable.** `library(statmod); library(mgcv); library(HDtweedie); library(TDboost); library(cplm)` all succeed. Do not check CRAN reachability.
- **H3. Eval API is reachable and validated.** Probe + body-validate in order: `EVAL_API_URL`, `http://localhost:8765`, `http://host.docker.internal:8765`, then ARP LAN discovery (only if no explicit URL). `/healthz` must return `{"ok": true}`; `GET /datasets` must be a manifest object listing at least one dataset; `GET /datasets/$EVAL_DATASET/info` must report `metric == "gini"`.
- **H4. Smoke fit succeeds end-to-end on trial 1 of the first dataset.** Fit Tweedie GLM on train/eval, compute non-NA Gini, call `predict_fn(test_df_raw)` and verify length + no NA/Inf + match-within-1e-6 to the procedure's own test predictions.

If any of H1–H4 fails, halt and report.

### 12.2 Soft checks — warn and proceed

These are sanity checks against the plan's API sketches; the installed package may have evolved. **Adapt the procedure code to the actual installed signature; do not halt.**

- `?HDtweedie::cv.HDtweedie`: confirm how τ / the mixing parameter is exposed (the sketch uses `alpha`). If different, adapt and log.
- `?TDboost::TDboost`: confirm `distribution = list(name = "EDM", alpha = ρ)`; if not, find the current way to specify Tweedie power.
- `?mgcv::Tweedie`: confirm `Tweedie(p = ρ)` is fixed-power; if renamed, use the current name.
- `?cplm::gini`: confirm `loss/score/base/data` argument names; adapt if changed.
- `splits/test.csv` (global, no `<k>`) has a `row_id` column and no response column.

A soft-check warning goes to stdout and the run log; it does **not** halt the orchestrator.

### 12.3 After preflight — run end-to-end automatically, no stopping

**Once all hard checks pass, execute the full benchmark without pausing, asking for confirmation, summarising setup progress, or handing off to the user:**

```bash
cd <workspace_root>
python agent/orchestrate.py
```

The agent's job is **not complete** until:
1. `results/summary.csv` exists with rows for every dataset, and
2. Every dataset's `summary.csv` has `mean_test_gini` populated (i.e., `score_dataset()` has run for every dataset).

**Do not stop after code generation, dependency checks, smoke tests, or any intermediate milestone.** Those are gates, not endpoints. Reporting "ready to run — execute this command to start" is a failure mode: the agent must run the command itself. **The default action is to act.** The only valid reasons to stop are: a hard preflight failure (H1–H4), a true uncertainty that requires a one-line bulleted question to the user, or an unrecoverable runtime error the orchestrator's retry path cannot resolve.

---

## 13. If a run fails

There is **no resume** within a dataset. If anything fails, re-run:

```bash
python agent/orchestrate.py
```

The orchestrator's per-trial skip logic (`status == OK` check, Section 8) prevents re-running already-successful trials. Incomplete datasets are wiped and restarted from round 1; fully complete datasets are preserved. The eval API's split-generation salts persist across restarts, so splits are bit-identical.

---

## Appendix A: Verification Checklist

A complete enumeration of observable, verifiable requirements with checking methods. Use this as a go/no-go review of any run. (Carried over from v1 and scrubbed to v4/v3 conventions: all-hyphen folder names, `autoclaim`, standard **error** not SD, no token tracking, `initial_prompt.md`.)

### Phase 0 — Workspace Setup & Isolation

| # | Requirement | How to verify |
|---|---|---|
| 0.1 | Workspace folder named `run-<harness>-<model>-<thinking>-<YYYYMMDD-HHMMSS>` (all hyphens, no underscores) | `basename $PWD` matches regex `^run-[a-z0-9.]+-(or-)?[a-z0-9.]+-[a-z-]+-[0-9]{8}-[0-9]{6}$` |
| 0.2 | `<thinking>` = `unknown` if `THINKING_LEVEL` unset; renamed after user confirms | Transcript shows thinking-level question after each dataset until confirmed |
| 0.3 | OpenRouter models carry the `or-` prefix; other sources do not | Folder token matches bootstrap prompt's model source |
| 0.4 | Agent's working directory is INSIDE this folder for all work | `pwd` in early commands; all file paths relative |
| 0.5 | No code copied from `archive/`, sibling runs, or `auto-insurance-bench-*` paths | Grep transcript: zero `cat`/`cp`/`ls` against those paths |
| 0.6 | `results/` not pre-populated; all files have mtime ≥ run start | `find results/ -newer <run_start_marker>` matches all |
| 0.7 | All code in `lib/`, `procedures/`, `agent/` written fresh | File mtimes ≈ run start; no "copied from" comments |
| 0.8 | No reading of other workspace results/logs/fitted objects | Transcript grep: zero references to other workspaces |
| 0.9 | Never read/list/grep `/Users/theo/Downloads/auto-insurance/do_not_read` or any path inside it | Transcript grep: zero `cat`/`ls`/`find`/`grep`/`Read`/`Glob` calls referencing `do_not_read` |
| 0.10 | `initial_prompt.md` written verbatim, once, at workspace creation | File exists; content is fenced raw prompt; mtime ≈ run start |

### Phase 1 — Environment Discovery

| # | Requirement | How to verify |
|---|---|---|
| 1.1 | API URL probed in order: `EVAL_API_URL` → `localhost:8765` → `host.docker.internal:8765` → ARP LAN | Read `orchestrate.py` `resolve_api_url()` |
| 1.2 | **Body-shape validation**, not status-only: `/healthz` == `{"ok":true}`, `/datasets` is a manifest object | Code: `validate_api()` checks body |
| 1.3 | LAN auto-discovery runs ONLY when no explicit URL and 1–3 fail; emits the pin-me WARN line | Code path + `WARN: eval API auto-discovered` |
| 1.4 | ~2.5-second timeout on probes | Code: `timeout=2.5` in `_get_json()` |
| 1.5 | Halts with clear error if all probes + discovery fail | Code: `raise SystemExit(...)` |
| 1.6 | `GET /datasets/<ds>/info` called; `metric == "gini"` confirmed | Transcript shows manifest fetch |
| 1.7 | Canonical order respected (`autoclaim` first), then API extras appended | `orchestrate.py` `CANONICAL_ORDER` exact |
| 1.8 | If `EVAL_DATASET` set, only that runs | Code: `[os.environ["EVAL_DATASET"]] if ...` |
| 1.9 | No hardcoded predictor names | Grep code; uses `info$numeric_predictors` etc. |
| 1.10 | Agent does NOT read API source code | Transcript grep: zero reads of API server files |

### Phase 2 — Wiki Consultation & Code Generation (if a wiki is present)

| # | Requirement | How to verify |
|---|---|---|
| 2.1 | Relevant concept pages read before the matching procedure script | Transcript timestamp ordering |
| 2.2 | Gini concept page read before `lib/gini.R` | Same |
| 2.3 | Leakage-audit page referenced if any eval Gini > 0.5 | Transcript ref |
| 2.4 | `?<function>` queried for each package | Transcript: `?HDtweedie::cv.HDtweedie`, etc. |
| 2.5 | Modeling decisions cite `[[PageName]]` in code comments | Grep procedures for `[[...]]` |
| 2.6 | Signature discrepancies logged (not halted) | Warnings present; code adapts |

### Phase 3 — Data Pipeline (`lib/data_loader.R`)

| # | Requirement | How to verify |
|---|---|---|
| 3.1 | Splits fetched via API URLs only | Grep `read.csv(sprintf("%s/datasets/...`; zero `load()`/`data()` |
| 3.2 | Train path: `/datasets/<ds>/splits/<k>/train.csv` | Exact pattern |
| 3.3 | Eval path: `/datasets/<ds>/splits/<k>/eval.csv` | Exact pattern |
| 3.4 | Test path: `/datasets/<ds>/splits/test.csv` (NO `<k>`) | Exact global path |
| 3.5 | Preprocessing state fitted on TRAIN only | Code shows `train_df` only in fit calls |
| 3.6 | Same fitted state applied to eval/test | `apply_preprocessing(eval_df, pre_state)` |
| 3.7 | `log1p` used (not `log`) for log transforms | Grep |
| 3.8 | Median imputation uses train medians | Code: state saved from `median(train_df...)` |
| 3.9 | Factor levels from train; unseen → train mode | Code: `factor(x, levels=train_levels)` + fallback |
| 3.10 | Polynomial expansion ONLY for grplasso/grpnet | `03`/`04` have poly; `01`/`02`/`05` do not |
| 3.11 | Each numeric's poly → one group; factor dummies → one group | `group_vec` NOT `1:ncol` |
| 3.12 | GAM uses `k = min(10, n_unique_values - 1)` | Grep `02_tweedie_gam.R` |
| 3.13 | `row_id` carried through untouched | Code: row_id in input + output, never transformed |

### Phase 4 — Model Implementations

| # | Requirement | How to verify |
|---|---|---|
| 4.1 | All 5 R packages loadable | Preflight `library()` succeeds |
| 4.2 | Tweedie power p = 1.7 in all 5 models | Grep all 5: `p = 1.7` / `var.power = 1.7` / `alpha = 1.7` |
| 4.3 | GLM: `tweedie(var.power = 1.7, link.power = 0)` | Grep `01_tweedie_glm.R` |
| 4.4 | GAM: `Tweedie(p = 1.7, link = "log")` — NOT `tw()` | Grep `02_tweedie_gam.R` |
| 4.5 | GAM: `method = "REML"` | Grep `02_tweedie_gam.R` |
| 4.6 | GrpLasso: `alpha = 1` in `cv.HDtweedie` | Grep `03_grplasso.R` |
| 4.7 | GrpNet: `alpha = 0.7` (< 1) in `cv.HDtweedie` | Grep `04_grpnet.R` |
| 4.8 | GrpLasso/GrpNet: `s = "lambda.min"` in predict | Grep both |
| 4.9 | TDboost: `distribution = list(name = "EDM", alpha = 1.7)` | Grep `05_tdboost.R` |
| 4.10 | TDboost: `best_iter` via `TDboost.perf(fit, method = "cv")` | Grep `05_tdboost.R` |
| 4.11 | TDboost: `attr(fit, "best_iter") <- best_iter` before `saveRDS` | Grep `05_tdboost.R` |
| 4.12 | GLM: no tuning | `01_tweedie_glm.R` has no `cv.*`/tuning loops |

### Phase 5 — Procedure Script Contract

| # | Requirement | How to verify |
|---|---|---|
| 5.1 | Accepts `--trial <int>` CLI arg | Grep each procedure: `commandArgs` + `--trial` |
| 5.2 | `set.seed(1000 + trial)` called early | Grep all 5 |
| 5.3 | Reads `EVAL_API_URL_RESOLVED` (NOT `EVAL_API_URL`) | Grep |
| 5.4 | Reads `EVAL_DATASET` | Grep |
| 5.5 | Fits on train, tunes on eval | Code flow |
| 5.6 | Computes `eval_gini` via `gini_insurance()` | Grep |
| 5.7 | Test JSON: `{model_id, row_ids, predictions}` | Open one JSON |
| 5.8 | `model_id` = `"<model>_v1"` | JSON inspection |
| 5.9 | Success: 4 artifacts (CSV/JSON/RDS/RDS) | `find results/<ds>/<model>/ -name "trial_01.*"` returns 4 |
| 5.10 | Error: only CSV with `status="ERROR: <msg>"` | Verify error trials lack JSON/RDS |
| 5.11 | Exit 0 on success, non-zero on uncaught failure | `echo $?` after manual run |
| 5.12 | Procedure does NOT call `/score` | Grep: zero `/score` or admin token usage |

### Phase 6 — Predict Closure

| # | Requirement | How to verify |
|---|---|---|
| 6.1 | Built with `local({...})` pattern | Grep procedures |
| 6.2 | Captures `pre_state`, `poly_state` (if grouped), `fit`, `best_iter` (if TDboost) | Code inspection |
| 6.3 | Works in fresh R session with only model package | Test: `R --vanilla -e 'predict_fn <- readRDS(...); predict_fn(df)'` |
| 6.4 | Does NOT call any function from `lib/data_loader.R` | Grep closure for `source(`/data_loader refs |
| 6.5 | Self-test runs `predict_fn(test_df_raw)` before saving | Grep procedure |
| 6.6 | Self-test verifies correct length, no NA, no Inf | Code |
| 6.7 | Self-test matches procedure's predictions within `1e-6` | Code: `all.equal(..., tolerance=1e-6)` |
| 6.8 | Self-test failure → raises, writes error-only CSV | Code path |

### Phase 7 — Gini Implementation

| # | Requirement | How to verify |
|---|---|---|
| 7.1 | `lib/gini.R` uses exact `cplm::gini()` call | File inspection |
| 7.2 | `baseline = 1` hardcoded | Code |
| 7.3 | Returns `g@gini[1, "prediction"] / 100` | Exact pattern |
| 7.4 | Not replaced with custom Lorenz | No alternative code |
| 7.5 | Eval Gini > 0.5 → leakage audit triggered | Transcript references leakage audit |

### Phase 8 — Orchestrator

| # | Requirement | How to verify |
|---|---|---|
| 8.1 | `logs/` wiped unconditionally at start | Code: `shutil.rmtree("logs")` |
| 8.2 | `results/history/` created at start | Code |
| 8.3 | Complete datasets preserved, incomplete wiped | Code: `_dataset_complete()` checks 50/50 OK |
| 8.4 | Round-robin: all 5 models per round before next round | Code: `for round_num: for model:` |
| 8.5 | Skip trials with `status == OK` | Code in `run_trial()` |
| 8.6 | Each trial run with env: `EVAL_API_URL_RESOLVED`, `EVAL_DATASET` | Code |
| 8.7 | `update_summary_and_archive()` called after EVERY trial | Code in `run_trial()` |
| 8.8 | `score_dataset()` called after each dataset's 50 trials | Code in main loop |
| 8.9 | Score POST uses `Authorization: Bearer test-token-12345` | Code inspection |
| 8.10 | Score reads `value` first, then `gini` | Code: `result.get("value", result.get("gini"))` |
| 8.11 | Score results saved to `results/<ds>/grader_scores/<model>_trial_NN.json` | File structure |
| 8.12 | No token tracking anywhere (no `tokens/` dir, no token CSV, no TokenTracker) | Grep code + tree: zero token artifacts |
| 8.13 | Final log line: `"All datasets complete."` | Last stdout line |

### Phase 9 — Session Log Capture

| # | Requirement | How to verify |
|---|---|---|
| 9.1 | `logs/session_snapshot.jsonl` is a real file (no `session.jsonl` symlink) | `stat` shows Regular File; `test ! -e logs/session.jsonl` |
| 9.2 | Snapshot grows monotonically (append-only) | size(trial N+1) ≥ size(trial N) |
| 9.3 | Snapshot updated after every trial | `stat` mtime ≈ last trial timestamp |
| 9.4 | Live JSONL pinned via env var, NEVER newest-mtime as primary | Code: `discover_harness_session()` reads env var first; mtime only after `[warn]`/`WARN` |
| 9.5 | Startup line `session JSONL pinned to <path>` written once | `grep "session JSONL pinned to"` returns one line |
| 9.6 | Target-change guard renames old snapshot to `session_snapshot.<prev>.jsonl` | Inspect code path; force a target change |
| 9.7 | End-of-run contamination scan writes `SNAPSHOT_CONTAMINATED.txt` only if >1 sessionId | `contamination_scan()` + file presence iff real |
| 9.8 | If harness JSONL not findable: warning logged, run proceeds | Transcript shows warning, not error |

### Phase 10 — Aggregator (`lib/aggregate.R`)

| # | Requirement | How to verify |
|---|---|---|
| 10.1 | `history/` excluded from dataset listing | Code: `setdiff(list.dirs(...), c("history"))` |
| 10.2 | Per-dataset `summary.csv` written (5 rows, omits `dataset` column) | `ls results/<ds>/summary.csv`; header check |
| 10.3 | Top-level `results/summary.csv` written (rows = N_datasets × 5) | Inspect |
| 10.4 | Columns: `n_completed, mean_eval_gini, se_eval_gini, mean_test_gini, se_test_gini, success_rate` (+`dataset`,`model`) | Open CSV, check header |
| 10.5 | `success = status == "OK" AND eval_gini not NA` | Code |
| 10.6 | `n_completed` = total rows (incl. errors) | Code: `nrow(trials)` |
| 10.7 | `mean_eval_gini` only on successful trials | Code: `mean(ok$eval_gini)` |
| 10.8 | `se_* = sd/sqrt(n)`; NA when < 2 valid values | Code: `se()` helper |
| 10.9 | Grader fallback: `value` → `gini` → NA | Code shows fallback chain |
| 10.10 | `success_rate` format `"X/10"` | CSV inspection |
| 10.11 | `results/history/summary_<timestamp>.csv` accumulates | `ls results/history/` shows N files |
| 10.12 | Consolidated `trials.csv` per model | File exists alongside per-trial files |
| 10.13 | No token columns anywhere | Header has no `*_tokens` |

### Phase 11 — Preflight

| # | Requirement | How to verify |
|---|---|---|
| 11.1 | **H1:** `results/` and `logs/` empty/absent | Pre-run `ls` |
| 11.2 | **H2:** All 5 R packages load | Preflight log |
| 11.3 | **H3:** API reachable + body-validated; target dataset metric == "gini" | Preflight log |
| 11.4 | **H4:** Smoke fit (GLM, trial 1) succeeds end-to-end | Preflight log |
| 11.5 | Soft checks logged as warnings, run proceeds | Warnings present, no halt |
| 11.6 | After preflight: run starts without pausing | No "ready to run, please confirm" |

### Phase 12 — Execution & Completion

| # | Requirement | How to verify |
|---|---|---|
| 12.1 | All datasets run to completion | Each `results/<ds>/summary.csv` exists |
| 12.2 | Each model: 10 trial CSVs (e.g. `autoclaim`) | `find results/ -name "trial_*.csv" \| wc -l` ≥ 50 per dataset |
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

**Total: ~100 verifiable requirements across 14 phases. A run that passes all of these is a clean, contamination-free benchmark execution that stays schema-compatible with v3 runs.**
