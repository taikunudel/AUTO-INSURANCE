# RUNBOOK — running the benchmark (operator-facing)

How to launch a benchmark agent and collect results. The benchmark agent's own
contract is `CLAUDE.md` — you don't need to read it to run a run. Everything to launch
is here; you never need `do_not_read/`. If you are a **master operator agent**
orchestrating whole runs (start → monitor → resume → evaluate), your playbook is
**`MASTER.md`**; this file is the launch-command reference it points into.

> **This branch (`no-wiki`):** there is no `knowledge-base/`. Always launch with
> `WIKI_VERSION=0` — run folders are named `…-wiki0-…`.

## Prereqs (once)
1. `./setup.sh` — R env + datasets (see README).
2. `cp .env.example .env`, then fill in `EVAL_ADMIN_TOKEN` and the login/API key for the
   harness(es) you'll use.
3. `./setup.sh --start-api`, then `curl localhost:8765/healthz` → `{"ok":true}`.
4. `./smoke.sh` passes (prints a Gini).

## The run environment (export before every launch)
```
EVAL_API_URL=http://localhost:8765   # where the agent scores
RUN_INDEX=1                          # seed base: per-trial seed = 1000*RUN_INDEX + trial
WIKI_VERSION=0                       # always 0 on this branch — no knowledge base present
THINKING_LEVEL=<level>               # recorded in the run; harness flag differs (below)
```
Load your `.env` first: `set -a; . ./.env; set +a`.

## The prompt
Fill `task_prompt.template.txt` (`{MODEL}`, `{HARNESS}`, `{THINKING}`, `{WORKSPACE}`,
`{WIKI_VERSION}`) → `task_prompt.txt`. It tells the agent to read `plan_v5.md` and
implement it end-to-end, creating a folder
`run-<harness>-<model>-<thinking>-run1-wiki<ver>-<UTC>`.

## Roster — the models to test (cross-harness)
The full grid is **`roster.yaml`** — one entry per (harness, model) with the exact
`model` string and `thinking` level each harness expects. Launch one run per entry
(same datasets, same prompt). At a glance:

| harness | models |
|---|---|
| claudecode | opus47 · sonnet46 |
| codex | gpt5.4 · gpt5.5 |
| antigravity | gemini31pro · gemini35flash |
| openclaw | glm5 · glm5.1 · glm5turbo · glm4.7 · gpt5.4 · gpt5.5 · or-gemini31pro · or-gemini35flash · or-gemma4 |

Exact `--model` strings + thinking levels live in `roster.yaml`.

## Launch — pick your harness (run from the repo root; each is nohup-detached)

**Claude Code**
```bash
EVAL_API_URL=$EVAL_API_URL RUN_INDEX=1 WIKI_VERSION=0 THINKING_LEVEL=max \
  nohup claude -p "$(cat task_prompt.txt)" --model <model-id> --effort max \
    --dangerously-skip-permissions --output-format json > run.log 2>&1 &
```

**Codex**
```bash
EVAL_API_URL=$EVAL_API_URL RUN_INDEX=1 WIKI_VERSION=0 THINKING_LEVEL=extra-high \
  codex exec "$(cat task_prompt.txt)" -C "$PWD" \
    -m <model-id> -c model_reasoning_effort=xhigh \
    --dangerously-bypass-approvals-and-sandbox
```

**Antigravity (`agy`)** — the "gemini" harness *is* antigravity, **not** the deprecated gemini CLI
```bash
EVAL_API_URL=$EVAL_API_URL RUN_INDEX=1 WIKI_VERSION=0 THINKING_LEVEL=high \
  nohup agy -p "$(cat task_prompt.txt)" --model "<Display Name>" \
    --dangerously-skip-permissions --print-timeout 4h > run.log 2>&1 &
# `agy models` lists the exact display names. --print-timeout must be long (default 5m).
```

**openclaw** — runs the agent inside its gateway; prone to a ~10-min provider RPC timeout
```bash
EVAL_API_URL=$EVAL_API_URL RUN_INDEX=1 WIKI_VERSION=0 THINKING_LEVEL=high \
  nohup openclaw agent --agent main --session-key agent:main:<key> \
    --model <provider/model> --thinking <on|high|xhigh> --timeout 14400 \
    --message "$(cat task_prompt.txt)" --json > run.log 2>&1 &
# zai GLM models reject `--thinking high` → use `--thinking on`.
```

## Completion & results
- Output lands in `run-…/results/summary.csv` — 24 rows (6 datasets × 4 models).
- **Complete = all 24 rows have a real (non-NA) `mean_eval_gini`.** Row count alone is
  not enough: a row can exist with NA if that model's eval failed.
- The headline metric is `mean_eval_gini` (Gini on the sealed test set, averaged over
  the 10 trials).
- Across runs: `python3 operator/collect-results.py` (completeness per run;
  `--tidy` dumps every row as CSV for comparison).

## If a run stops short (openclaw timeouts, external kills)
The resume loop re-runs the agent against its on-disk progress until 24 are scored,
backing off through provider rate-limits:
```bash
python3 operator/auto-resume.py <run_folder> <session-key> <provider/model> [think_flag] [think_label]
# several models back-to-back (avoids shared-quota throttling):
python3 operator/auto-resume-sequential.py
```
Keep the API alive during long runs: `nohup bash operator/eval-api-watchdog.sh &`.

## Eval API reference (what the agent talks to)
| route | purpose |
|---|---|
| `GET  /healthz` | `{"ok":true}` |
| `GET  /datasets` | list + row counts |
| `GET  /datasets/<name>/info` | response var, predictors, metric, `n_trials` |
| `GET  /datasets/<name>/splits/<k>/train.csv` | trial-k training rows (labeled) |
| `GET  /datasets/<name>/splits/<k>/eval.csv` | trial-k eval rows (labeled, for tuning) |
| `GET  /datasets/<name>/splits/test.csv` | the sealed **global** test set (features only) |
| `POST /datasets/<name>/score/<k>` | submit test predictions → Gini (Bearer token) |

Scoring is on the **sealed test set** (not the eval split). Submit:
```json
{"model_id":"my-model","row_ids":["r_…", …],"predictions":[…]}
```
with header `Authorization: Bearer $EVAL_ADMIN_TOKEN`. `row_ids` must be exactly the
test set's ids; `predictions` must be non-NA. Response: `{"value": <gini>, "se": …}`.
