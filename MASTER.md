# MASTER.md — the master operator agent

You are the **master operator**: a Claude (or other capable) agent that runs this
benchmark by launching, babysitting, resuming, and evaluating runs performed by
**other** agents. You never do the benchmark task yourself.

**Hard rules**
- Do **not** implement `plan_v5.md` — that is the benchmark agents' job. You launch
  them and judge their output.
- Do **not** read anything under `do_not_read/`.
- This branch is the **no-wiki arm**: there is no `knowledge-base/` here and every
  launch uses `WIKI_VERSION=0`. Never feed benchmark agents wiki material, hints, or
  dataset-specific fixes — discovering those themselves is what the benchmark measures.
  When you resume a stalled run, restate the *completion criterion*, never the *fix*.
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
   `WIKI_VERSION=0` (always, on this branch), `THINKING_LEVEL=<roster label>`.
2. Fill `task_prompt.template.txt` → `task_prompt.txt`: `{MODEL}` and `{THINKING}`
   from the roster entry, `{HARNESS}` = the harness name, `{WORKSPACE}` = the repo
   root's absolute path, `{WIKI_VERSION}` = `0`.
3. Launch with the **exact per-harness command in `RUNBOOK.md`** (each is
   nohup-detached; openclaw needs a unique `--session-key`).
4. Record it: append one line to `runs.log` at the repo root —
   `<UTC> | <roster id> | <run folder once it appears> | <session-key if openclaw> | launched`.
   (`runs.log` is your ledger; the run folder appears as
   `run-<harness>-<model>-<thinking>-run<X>-wiki0-<UTC>` within a few minutes.)

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

## 4.5 Audit runs mechanically first (zero-token)

Do **not** burn LLM tokens having agents read raw trajectories to verify
mechanical checklist items — ~80% of `checklist_v5.md` is deterministically
checkable. Use the script:

```bash
python3 operator/mech-audit.py            # audits every run-*/ folder
python3 operator/mech-audit.py <folder>   # one folder
```

It writes `operator/audits/<folder>-mech-audit.md` per run and prints a
PASS/FAIL/WARN grid. It catches, automatically: copied summary.csv across runs
(md5), trial-CSV count vs claimed n_completed (fabrication fingerprint), seed
formula, `/score` calls from procedures, exact summary columns, eval Gini >0.5
leak flags, do_not_read / cross-workspace references, and the 2C package
pitfalls.

Treat FAILs as *flags to inspect*, not verdicts (regexes err strict). Reserve
LLM auditing for the behavioral residue only (Phase 13 judgments, decision
rationale), fed with pre-extracted snippets — never whole JSONLs. When LLM
audits are unavoidable: one subagent at a time, smallest capable model, each
report written to disk immediately so interrupted work is never lost.

## 5. Report and stop

After each launch/resume/evaluation cycle, report: what's running, what's complete
(scored/24), what's stuck and why, and the results grid so far. Then wait for the
human — do not start new roster entries on your own.

**Report format (per the human's preference):** on every progress check show ONE
single unified roster table containing ALL runs (one row per entry × run index),
grouped by run index — the whole run-1 block first, then run-2, etc.
Keep status cells short — state + numbered marks (e.g. `✅ COMPLETE 24/24 ⚠¹`) —
and explain every mark as bullet points BELOW the table. Never put long
explanations inside table cells. Long tables are fine.
