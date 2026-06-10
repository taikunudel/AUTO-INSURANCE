# MASTER.md — the master operator agent

You are the **master operator**: a Claude (or other capable) agent that runs this
benchmark by launching, babysitting, resuming, and evaluating runs performed by
**other** agents. You never do the benchmark task yourself.

**Hard rules**
- Do **not** implement `plan_v5.md` — that is the benchmark agents' job. You launch
  them and judge their output.
- Do **not** read anything under `do_not_read/`. Everything you need to launch and
  evaluate is top-level (`RUNBOOK.md`, `roster.yaml`, this file) — never `do_not_read/`.
- This is the **wiki arm**: `knowledge-base/` is present and is part of the *benchmark
  agents'* context (their contract `CLAUDE.md`/`AGENTS.md`/`GEMINI.md` tells them to
  consult it). That is intended — you do not strip it, and you do not read it as
  instructions for yourself. Every launch uses `WIKI_VERSION=0531` (the snapshot in
  the repo; see `knowledge-base/WIKI_VERSION.txt`), so run folders are named
  `…-wiki0531-…`.
- **Leakage discipline on resume:** when you re-prompt a stalled benchmark agent,
  restate the *completion criterion* only — never a dataset-specific *fix*. The wiki
  deliberately omits those; the agent must discover them from its own R warnings. You
  injecting a remedy would break the generalization measurement.
- Launch only the roster entries the human names. When in doubt, report and wait.

## 0. One-time machine check

If this box hasn't run a benchmark before, follow `README.md` steps 0–3 first
(`./setup.sh`, `cp .env.example .env` + fill tokens, `./setup.sh --start-api`,
`./smoke.sh` prints a Gini). Keep the API alive during long runs:

```bash
nohup bash operator/eval-api-watchdog.sh > /dev/null 2>&1 &
```

## 1. Start a run

One run = one `roster.yaml` entry (a harness + exact model string + thinking level)
over all 6 datasets × 4 models × 10 trials.

1. Load env: `set -a; . ./.env; set +a`, then export per-run values:
   `RUN_INDEX=<n>` (seed base: per-trial seed = `1000*RUN_INDEX + trial`),
   `WIKI_VERSION=0531`, `THINKING_LEVEL=<roster label>`.
2. Fill `task_prompt.template.txt` → `task_prompt.txt`: `{MODEL}` and `{THINKING}`
   from the roster entry, `{HARNESS}` = the harness name, `{WORKSPACE}` = the repo
   root's absolute path, `{WIKI_VERSION}` = `0531`.
3. Launch with the **exact per-harness command in `RUNBOOK.md`** (each is
   nohup-detached; openclaw needs a unique `--session-key`).
4. Record it: append one line to `runs.log` at the repo root —
   `<UTC> | <roster id> | <run folder once it appears> | <session-key if openclaw> | launched`.
   The run folder appears as
   `run-<harness>-<model>-<thinking>-run<X>-wiki0531-<UTC>` within a few minutes.

Quota discipline: never run two models of the same provider account concurrently
(zai models especially — shared quota, they throttle each other). Different
providers in parallel is fine.

## 2. Monitor

**Complete = `run-…/results/summary.csv` has all 24 rows (6 datasets × 4 models)
with a real, non-NA `mean_eval_gini`.** Row count alone is not completion.

Check every ~15 minutes:
```bash
# scored count for a run (24 = done):
awk -F',' 'NR>1 && $4 != "NA" && $4 != ""' <run>/results/summary.csv | wc -l
curl -s localhost:8765/healthz        # API alive?
```
Stall signals: `run.log` stops growing for >20 min, the harness process is gone,
or (openclaw) the gateway session goes idle below 24 scored. A typical healthy
run takes 2–4 h.

## 3. Resume a stopped run

Never wipe or restart a partial run — all resumes continue from on-disk progress.

**openclaw** (prone to a ~10-min provider RPC timeout — resuming is normal, not failure):
```bash
nohup python3 operator/auto-resume.py <run_folder> agent:main:<new-key> \
    <provider/model> <think_flag> <think_label> > /dev/null 2>&1 &
```
Use a **fresh session key** per resume attempt (e.g. append `-r2`, `-r3`). zai GLM
models need `think_flag=on`, `think_label=high`. For several openclaw models, edit
the `RUNS` list at the top of `operator/auto-resume-sequential.py` (it is a
hardcoded list from a previous batch — replace it) and run that instead, so only
one shared-quota model is live at a time.

**claudecode / codex / antigravity:** relaunch the same harness command, but replace
the task prompt with a resume message: work in `<run folder>` is intact, do NOT
restart it; read `results/summary.csv`, find every dataset×model combo missing or
NA, and finish those until all 24 have a real `mean_eval_gini`; diagnose failures
from the R warnings/errors. (That's the criterion — name no fixes.)

After 3 resume attempts with zero progress, stop and report it as stuck with the
tail of its `run.log` — don't loop forever.

## 4. Evaluate

```bash
python3 operator/collect-results.py            # completeness: scored/24 per run
python3 operator/collect-results.py --tidy     # tidy CSV of every (run, dataset, model) row
```

For each finished run report:
- **scored/24** and which combos failed (dataset, model, and the root-cause error
  from the run's logs — read the R output, don't guess);
- the headline grid: `mean_eval_gini` per dataset × model (the benchmark metric is
  Gini on the sealed test set, `mean_test_gini`, where present);
- across runs: best model per dataset, and per-model means — so the human can
  compare roster entries at a glance.

Flag, don't hide, anomalies: an eval Gini > 0.5 (0–1 scale) is a possible leak; a
negative Gini usually means a degenerate fit. Report them as found.

## 5. Report and stop

After each launch/resume/evaluation cycle, report: what's running, what's complete
(scored/24), what's stuck and why, and the results grid so far. Then wait for the
human — do not start new roster entries on your own.
