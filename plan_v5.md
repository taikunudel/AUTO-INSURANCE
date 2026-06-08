# Auto Insurance Pricing Model Benchmark — Agent Execution Plan (v5)

## Folder Naming — READ THIS FIRST (non-negotiable)

Every run lives in a workspace folder whose name follows this exact pattern —
**all lowercase, hyphens only, NO underscores anywhere**:

```
run-<harness>-<model>-<thinking>-run<X>-wiki<MMDD>-<YYYYMMDD-HHMMSS>
```

- **`<harness>`** — the CLI you run under: `claudecode`, `codex`, `openclaw`, or `gemini`.
- **`<model>`** — a short id for the underlying model (e.g. `opus47`, `sonnet46`, `gpt5.4`, `gemini31pro`, `glm47`, `qwen35`).
  - **OpenRouter rule:** if your bootstrap prompt names the model like `openrouter/google/gemini-3.1-pro-preview`, the model is served through **OpenRouter** — prefix the token with **`or-`** → `or-gemini31pro`.
  - Models reached any other way — Google's Gemini API via the `gemini` harness, OpenAI, Anthropic, or a self-hosted **vLLM** endpoint — get **no** prefix.
- **`<thinking>`** — reasoning level: `low` / `medium` / `high` / `max` / `xhigh` / `extra-high` / `off` / … (hyphens, never spaces or underscores).
- **`run<X>`** — the run index, `X` an integer (`run1`, `run2`, `run3`). The operator sets it at launch; it pins the random seed so all agents' `run1` share one seed, all `run2` another, etc. (see §7).
- **`wiki<MMDD>`** — which wiki snapshot this run consulted, `MMDD` = its date: `wiki0530` (original) or `wiki0531` (updated). The operator sets it.
- **`<YYYYMMDD-HHMMSS>`** — wall-clock folder-creation time, date and time joined by a hyphen (e.g. `20260527-075515`). **No underscore.**

### Worked examples — copy the pattern

| Situation | Folder name |
|---|---|
| Claude Code · Opus 4.7 · max · run1 · wiki 0531 | `run-claudecode-opus47-max-run1-wiki0531-20260527-075454` |
| Codex · GPT-5.4 · extra-high · run2 · wiki 0531 | `run-codex-gpt5.4-extra-high-run2-wiki0531-20260526-101752` |
| Gemini CLI · Gemini 3.5 Flash (Google direct) · run1 · wiki 0530 | `run-gemini-gemini35flash-high-run1-wiki0530-20260527-075533` |
| openclaw · Gemini 3.1 Pro **via OpenRouter** · run3 · wiki 0531 | `run-openclaw-or-gemini31pro-high-run3-wiki0531-20260529-032103` |
| openclaw · GLM-4.7 **via OpenRouter** · run1 · wiki 0531 | `run-openclaw-or-glm47-high-run1-wiki0531-20260528-172557` |
| openclaw · Qwen3.5-35B **via vLLM** (not OpenRouter) · run1 · wiki 0530 | `run-openclaw-qwen35-off-run1-wiki0530-20260528-080707` |

**The same model from two sources gets two different names:** `gemini35flash`
(Google, under the `gemini` harness) vs `or-gemini35flash` (OpenRouter, under
e.g. openclaw). The `or-` prefix is the *only* thing that distinguishes the
source — get it right.

---

## 0. No reuse of prior runs

This is a fresh-each-time benchmark. Every implementation run must:

- **Start from an empty workspace.** Do not copy code, scripts, models, predictions, fitted objects, or summary CSVs from any prior benchmark run, your own or anyone else's. The reference for what to build is this plan, not other people's results directories.
- **Never read, list, search, or reference `/Users/theo/Downloads/auto-insurance/do_not_read` or any path inside it.** This folder is explicitly off-limits. Do not `cat`, `ls`, `find`, `grep`, `head`, `tail`, `Read`, `Glob`, or otherwise inspect it under any circumstances. Treat its existence as if it were not there. This restriction is non-negotiable and independent of any other path-exclusion rule.
- **Not pre-populate `results/` with anything.** The orchestrator wipes any *unfinished* dataset directory on every invocation but **preserves dataset directories that are fully complete** from a prior run on the same workspace (40/40 successful trials, i.e. 4 models × 10 trials with status OK — see Section 8). Your scripts must not write into `results/` before the orchestrator runs.
- **Re-derive every artifact this run.** Models, predictions, predict-fn closures, summary tables — all of them must be the output of this run's procedure scripts, fitted on this run's API-served splits.
- **Treat all other runs — whether currently in progress or already finished — as completely out of scope.** This plan is routinely executed in parallel across multiple independent workspaces. No run may read, inspect, copy, or draw any inference from another run's workspace, results directory, logs, code, scripts, fitted objects, or outputs, regardless of whether that other run is still running or has fully completed. Do not reuse code from other runs — all scripts (`lib/`, `procedures/`, `agent/`) must be written from scratch using this plan as the sole reference. Every run is a sealed, self-contained unit.

Reusing prior runs is the single largest source of contamination across agent comparisons (different splits, stale preprocessing, leaked test labels). The orchestrator's wipe-on-start is a backstop; the primary defense is the agent following this directive.

---

## 1. Experiment overview

This experiment benchmarks four Tweedie-family regression models on an auto insurance claim dataset, measuring how well each model ranks policyholder risk. Data is served exclusively by the sealed eval API at `EVAL_API_URL`; the agent does not know the underlying data source, does not load any raw file or R-package dataset directly, and does not read the API's source code. All four models share the Tweedie compound Poisson loss family, which makes their predictions directly comparable via the Gini index of the ordered Lorenz curve — the standard insurance-pricing metric for risk segmentation.

The benchmark measures two things per model:

1. **Gini index** — predictive ranking quality, individual (not pairwise), with constant baseline premium M(x) ≡ 1.
2. **Success rate** — fraction of trials (out of 10) that produce a complete metric row.

**Datasets — all by default, in the canonical priority order below.** The eval API hosts several insurance datasets (`GET /datasets` lists them). By default the orchestrator runs the full 4-models × 10-trials benchmark on each dataset, one at a time, in this fixed order:

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

Each model is run **10 times**. The eval API holds a **single global test set** (~20% of rows, sealed labels) carved out once at startup — every trial scores against the same test set. The remaining ~80% is re-split per trial into train (~70%) and eval (~10%). Execution is **round-robin and strictly sequential**: round 1 runs all 4 models on `(train_1, eval_1)`, then round 2, and so on.

The agent saves test predictions as JSON files and the **grader** — who holds the API admin token — runs `POST /datasets/$EVAL_DATASET/score/<k>` afterward to compute the authoritative test Gini. The orchestrator runs this grader pass immediately after each dataset's 40 trials complete (Section 8), so `mean_test_gini` is populated before the agent moves to the next dataset.

---

## 2. The four models

> **v5 note:** Tweedie GLM has been removed from this benchmark. The four models below are what every run builds. (The wiki may still contain GLM material — that is fine; just do not build a GLM here.)

**Tweedie GAM.** Generalized additive model with Tweedie family. Each numerical predictor enters through a penalized smoothing spline; categorical predictors enter as factors. Captures arbitrary smooth main effects but interactions must be specified explicitly.

**GrpLasso.** Tweedie grouped-lasso GLM. Predictors are partitioned into blocks (e.g., a categorical's dummy variables, or a numerical's polynomial expansion); the penalty selects or zeros out each block as a unit.

**GrpNet.** Tweedie grouped elastic-net GLM. Same as GrpLasso but with an additional L2 component (mixing parameter τ < 1), which handles correlated blocks better.

**TDboost.** Gradient tree-boosted Tweedie compound Poisson model. Captures arbitrary nonlinearities and high-order interactions automatically.

---

## 3. Models and packages

**Packages required:** `mgcv` (GAM), `HDtweedie` (GrpLasso/GrpNet), `TDboost`, `cplm` (Gini metric).

**Tweedie power: use p = 1.7 for all four models** (fixed, not estimated — consistent across models for comparability).

**If a knowledge wiki exists at `/Users/theo/Downloads/auto-insurance/knowledge-base/knowledge/wiki/`, consult it before writing any model code** — it will likely contain useful concepts and code (calling conventions, common pitfalls, Tweedie-specific arguments, the Gini calculation, the leakage audit). Navigate it independently; there is no prescribed reading order. Whether or not a wiki is present, adapt to whatever package signatures are installed and log any discrepancies — do not halt.

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

**Preprocessing — agent's call, fit on train only.** The agent decides what to apply after exploring trial 1's train side, then **fits all preprocessing state on `train` only** and applies that state unchanged to `eval` and `test`. State includes scaling, factor levels, NA imputers, polynomial bases, and any other transforms the agent chose. Consult the wiki (if present) for model-specific preprocessing conventions and pitfalls; otherwise apply sensible defaults from first principles. Note that `grplasso`/`grpnet` additionally need a grouped design matrix (one group per numeric block, one group per factor's dummy set), while `gam`/`tdboost` do not.

This logic lives in `lib/data_loader.R` and is shared by all four procedures. The exact same logic must drive the predict-fn closures (Section 7.1).

**Note on `row_id`.** Treat it as an opaque token. Carry it through preprocessing untouched.

---

## 5. Gini index (M(x) ≡ 1)

The benchmark metric is the Gini index of the **ordered Lorenz curve** with constant baseline premium M(x) ≡ 1. If a knowledge wiki is present, it will likely contain a useful Gini concept page with implementation guidance; otherwise the agent implements `lib/gini.R` from first principles. Each procedure script computes `eval_gini` on its eval predictions and writes it to the trial CSV (Section 7). The agent does **not** compute test Gini — that is the orchestrator's job, via its grader pass (Section 8), which scores the saved test predictions through the eval API.

**Scale — report `eval_gini` as a 0–1 fraction.** Some implementations (e.g. `cplm::gini`) return the ordered Gini on a **0–100 percent** scale. `eval_gini` written to the trial CSV must be on the **0–1 fraction** scale, matching the grader's `test_gini`. If your Gini routine returns 0–100, divide by 100 before writing it. (This also makes the leakage-audit threshold below correct.)

**Leakage audit.** If any trial's `eval_gini` comes out **> 0.5** (on the 0–1 scale), treat it as a possible leak (a predictor echoing the response, a row_id ordering artifact, etc.). Re-check preprocessing and the train/eval/test boundary before trusting the number; consult the wiki's leakage-audit page if present.

---

## 6. Project structure

**Workspace folder naming.** Worked examples are in **Folder Naming — READ THIS FIRST** at the top of this plan. The pattern (all lowercase, hyphens only, **no underscores anywhere**):

```
run-<harness>-<model>-<thinking>-run<X>-wiki<MMDD>-<YYYYMMDD-HHMMSS>
```

where:
- `<harness>`: `claudecode`, `codex`, `openclaw`, or `gemini`
- `<model>`: a short id for the model, e.g., `sonnet46`, `opus47`, `gpt5.4`, `gemini31pro`, `glm47`, `qwen35`. **If the model is served via OpenRouter** (the bootstrap prompt names it like `openrouter/...`), prefix the token with `or-` (e.g., `or-gemini31pro`, `or-glm47`). Models reached any other way — Google's Gemini API via the `gemini` harness, OpenAI, Anthropic, or a self-hosted vLLM endpoint — get no prefix.
- `<thinking>`: a short lowercase label for this run's thinking/reasoning level — read from the `THINKING_LEVEL` environment variable if set. Common values are `low`, `medium`, `high`, but the user may self-define any label they like (e.g., `extra-high`, `ultra`, `xhigh`). Use hyphens, never spaces or underscores. If `THINKING_LEVEL` is not set and the agent is unsure, use `unknown` and proceed with the full benchmark immediately. After each dataset completes, ask the user once for the thinking level; keep asking after each subsequent dataset until a value is confirmed. Once confirmed, rename the workspace folder and all embedded paths replacing `unknown` with the confirmed value.
- `run<X>`: the run index (`run1`, `run2`, …), read from the `RUN_INDEX` environment variable the operator sets (default `run1`). It pins the random seed (§7).
- `wiki<MMDD>`: the wiki snapshot consulted (`wiki0530` / `wiki0531`), read from the `WIKI_VERSION` environment variable the operator sets.
- `<YYYYMMDD-HHMMSS>`: wall-clock timestamp at folder-creation time, date and time joined by a hyphen (no underscore)

Results are nested by dataset:

```
run-<harness>-<model>-<thinking>-run<X>-wiki<MMDD>-<timestamp>/
├── README.md
├── initial_prompt.md           ← verbatim first user prompt that bootstrapped this run
├── lib/
│   ├── data_loader.R
│   ├── gini.R
│   └── aggregate.R
├── procedures/
│   ├── 01_tweedie_gam.R
│   ├── 02_grplasso.R
│   ├── 03_grpnet.R
│   └── 04_tdboost.R
├── agent/
│   └── orchestrate.py
├── results/
│   ├── <dataset>/
│   │   ├── tweedie_gam/
│   │   │   ├── trials/trial_NN.csv
│   │   │   ├── predictions/trial_NN.json
│   │   │   ├── models/trial_NN.rds
│   │   │   ├── predict_fns/trial_NN.rds
│   │   │   └── trials.csv
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

### 6.1 Initial prompt capture

At workspace creation, the agent writes the **verbatim first user prompt** that bootstrapped this run to `initial_prompt.md` at the workspace root. Write once, never modify after.

The first user prompt naturally encodes the run's settings — model, thinking level, dataset selection, any overrides — in whatever phrasing the user chose. Saving it verbatim is the only reliable record of how this run was configured when many parallel experiments use different prompts. Folder name + this file = "what did I ask the agent to do, this time".

Format: a markdown file with the prompt text inside a triple-backtick fence (no edits, no summarization). If the bootstrap was multi-turn, include each user turn separated by a `---` line. If the agent was invoked non-interactively with no user prompt (e.g., a cron job), write a short note explaining the trigger.

### 6.2 Session log capture

The agent must capture its own harness session JSONL into `logs/` so the trajectory is auditable even if the run stops mid-way. One artifact only:

- **`logs/session_snapshot.jsonl`** — an append-only real file. After every trial, only new bytes from the live harness JSONL are appended to this file. It grows monotonically: never shrinks, never loses earlier content. Survives moving the workspace or deletion of the harness session file. There is **no** `session.jsonl` symlink — the snapshot is the single canonical capture artifact.

If the harness JSONL cannot be located, log a warning and proceed; do not halt.

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
3. **End-of-run contamination scan.** After the final dataset and grader pass, scan `session_snapshot.jsonl` for distinct `sessionId` values (the harness emits one per line). If more than one is found, write `logs/SNAPSHOT_CONTAMINATED.txt` listing every offending `sessionId` and the cause, and emit a `WARN:` to `orchestrator.log`. The benchmark still counts as complete, but the contamination is now loud rather than silent.

These three guards together ensure that even if the env-var lookup is somehow wrong, the contamination cannot stay hidden.

---

## 7. Procedure script contract

Each `procedures/0X_<model>.R`:

1. Takes CLI arg: `--trial <int>` (1 through 10).
2. Sets seed `1000 * RUN_INDEX + trial` for reproducible fitting/CV behavior, where `RUN_INDEX` is the integer read from the `RUN_INDEX` environment variable (default `1`). So `run1` → seeds 1001..1010, `run2` → 2001..2010, etc. This makes all agents' `run1` use the same seed, all `run2` the same, etc., while different run indices draw fresh CV folds. (The train/eval/test splits themselves come from the API and are unaffected by this seed; only model-internal CV/fold randomness is.)
3. Reads `EVAL_API_URL_RESOLVED` and `EVAL_DATASET` from the environment.
4. GETs `train.csv` and `eval.csv` for the trial plus the global `test.csv`.
5. Preprocesses via `lib/data_loader.R` — fits scaler/imputer/factor-levels/polynomial-basis on **train** only, then applies to **eval** and **test**. Carries `row_id` through unchanged.
6. Fits on **train**, tunes on **eval** per the wiki's tuning guidance for each model.
7. Predicts on **eval**, computes `eval_gini` via `lib/gini.R` (on the **0–1 fraction** scale — see §5).
8. Predicts on **test**, saves `results/<dataset>/<model>/predictions/trial_<trial>.json` with `{model_id: "<model>_v1", row_ids: <test$row_id>, predictions: <test predictions>}`.
9. **Writes four artifacts on success**:
   - `trials/trial_<trial>.csv` with columns `trial, eval_gini, n_active, fit_time, status`.
   - `predictions/trial_<trial>.json` — test predictions.
   - `models/trial_<trial>.rds` — fitted model (with any tuning state the predict closure needs, e.g., best-iter for boosted models).
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

Save it to `results/<dataset>/<model>/predict_fns/trial_<NN>.rds`. Two requirements:

1. **No external dependencies at predict time.** The closure must work in a fresh R session with only base R plus the model package. It must capture every piece of preprocessing state it needs (scalers, imputers, factor levels, polynomial basis, the fitted model itself, any tuning state) inside its environment, and must NOT call any agent function from `lib/data_loader.R`.
2. **Self-test before saving.** Call `predict_fn(test_df_raw)` and verify: correct length, no NAs/Infs, matches the procedure's own test predictions within `1e-6`. If the self-test fails, raise and write the error-only trial CSV.

---

## 8. Orchestration — round-robin, sequential, fresh-each-run

The orchestrator lives at `agent/orchestrate.py` and is the single entry point for a run. The agent designs and writes the script; the plan only specifies the required behavior. Pick whatever Python style, libraries, and helper structure fit best.

**API URL resolution at startup.** Probe the eval API in order: explicit `EVAL_API_URL` env var → `http://localhost:8765` → `http://host.docker.internal:8765`. Use the first one whose `/healthz` endpoint answers within a short timeout (~2s). If none respond, halt with a clear error that lists what was tried.

**Dataset selection.** If `EVAL_DATASET` is set in the env, run only that dataset. Otherwise fetch the list from `GET /datasets`, order by the canonical priority (`autoclaim`, `fremtpl2`, `bemtpl97`, `ausprivauto`, `swautoins`, `sgautonb`), then append any extras the API returned in API-given order.

**Workspace preparation (every invocation).**
- Wipe `logs/` and recreate it, including a `r_subprocess/` subdirectory.
- Ensure `results/history/` exists.
- For each existing dataset directory under `results/`: keep it untouched if it is *fully complete* (all 4 models × 10 trials with `status == "OK"`); otherwise wipe it.
- Initialize the session log artifacts as described in §6.1.

**Execution loop.** For each dataset, in order:

1. For each round `k` in 1..10 (outer), for each of the 4 models (inner):
   - Skip the trial if `results/<dataset>/<model>/trials/trial_<NN>.csv` already exists with `status == "OK"`.
   - Otherwise create the per-model subdirectories (`trials/`, `predictions/`, `models/`, `predict_fns/`) and run `Rscript procedures/0X_<model>.R --trial <k>` in a subprocess with `EVAL_API_URL_RESOLVED`, `EVAL_DATASET`, and `RUN_INDEX` exported. Capture stdout+stderr to `logs/r_subprocess/<dataset>_<model>_round<k>_<timestamp>.log`.
   - If the subprocess produced no trial CSV, log a warning and continue.
   - After every trial (success or not): regenerate the summary (call `lib/aggregate.R::write_summary()`), copy `results/summary.csv` to `results/history/summary_<timestamp>.csv`, and append any new bytes from the live harness JSONL to `logs/session_snapshot.jsonl` — see §6.1.

2. After all 40 trials for the dataset complete, run the grader pass: for every saved `predictions/trial_<NN>.json`, POST its body to `/datasets/<dataset>/score/<NN>` with header `Authorization: Bearer test-token-12345` and `Content-Type: application/json`. Save the JSON response to `results/<dataset>/grader_scores/<model>_trial_<NN>.json`. Tolerate missing prediction files and per-trial scoring errors (log and continue). Regenerate the summary one more time so the test-Gini columns are populated.

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
| `model` | one of the four model names |
| `n_completed` | total trial rows present (successes + errors) |
| `mean_eval_gini`, `se_eval_gini` | agent-side stats, computed over successful trials only |
| `mean_test_gini`, `se_test_gini` | grader-side stats, from the JSON scores |
| `success_rate` | `"X/10"` string |

A trial is **successful** iff `status == "OK"` AND `eval_gini` is non-NA. Report **standard error of the mean** (`se = sd / sqrt(n_successful)`) — *not* the standard deviation across seeds. SE quantifies uncertainty in the estimated mean and is the correct unit for cross-method comparisons; SD describes run-to-run spread and is not used here. Use `NA` for any `se_*` when fewer than 2 valid values are available. Use `NA` for any `mean_*` when there are zero valid values.

**Outputs (every call).**
- `results/<dataset>/<model>/trials.csv` — consolidated view of that model's per-trial CSVs (concatenated).
- `results/<dataset>/summary.csv` — 4 rows, one per model.
- `results/summary.csv` — top-level, rows = dataset × model, combining all datasets.

When walking dataset directories under `results/`, ignore the `history/` directory.

---

## 10. Final summary table format

Two levels: per-dataset `results/<dataset>/summary.csv` (4 rows, one per model) and the top-level `results/summary.csv` (rows = `dataset × model`). Columns:

| dataset | model | n_completed | mean_eval_gini | se_eval_gini | mean_test_gini | se_test_gini | success_rate |

`*_eval_gini` = agent-side values (0–1 fraction scale). `*_test_gini` = grader-side values from the orchestrator's grader pass (Section 8). `se_*` is the **standard error of the mean** across successful trials (`sd / sqrt(n_successful)`), not the raw standard deviation across seeds — it is the right unit for comparing methods.

---

## 11. Trial success criterion

A trial counts as successful iff: `status == "OK"` AND `gini` is non-NA. Per-model success rate = (successful trials) / 10. Updated in `summary.csv` after every trial.

---

## 12. Pre-run verification checklist

**Philosophy.** The preflight is a *go/no-go* gate, not an audit. Halt **only** when the run literally cannot succeed. Log warnings for everything else and proceed.

### 12.1 Hard checks — halt if any fails

- **H1. Workspace is empty.** `results/` and `logs/` either do not exist or are empty.
- **H2. R packages are loadable.** `library(mgcv); library(HDtweedie); library(TDboost); library(cplm)` all succeed.
- **H3. Eval API is reachable.** Probe in order: `EVAL_API_URL`, `http://localhost:8765`, `http://host.docker.internal:8765`. `GET /datasets` must list at least one dataset; `GET /datasets/$EVAL_DATASET/info` must report `metric == "gini"`.
- **H4. Smoke fit succeeds end-to-end on trial 1 of the first dataset.** Fit the Tweedie GAM on train/eval, compute non-NA Gini, call `predict_fn(test_df_raw)` and verify length + no NA/Inf.

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

The orchestrator's per-trial skip logic (`status == OK` check, see Section 8) prevents re-running already-successful trials. Incomplete datasets are wiped and restarted. The eval API's split-generation salts persist across restarts, so splits are bit-identical.
