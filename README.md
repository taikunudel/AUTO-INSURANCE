# auto-insurance — an LLM-agent generalization benchmark

> **Branch note:** this is the **`no-wiki` branch** — the control arm with **no
> `knowledge-base/`**. Agents work from their own knowledge + execution feedback
> only, and every run is labeled `wiki0`. The wiki arm lives on `main`. This branch
> also adds **`MASTER.md`**: the playbook for a master operator agent that starts,
> resumes, and evaluates runs.

This repo runs a benchmark where an **AI coding agent** is dropped into a workspace and
asked to autonomously write R that fits four Tweedie-family models (`tweedie_gam`,
`grplasso`, `grpnet`, `tdboost`) across **six held-out insurance datasets**, scoring
each by **Gini** against a sealed eval API. The agent must discover dataset-specific
fixes itself, from its own model warnings and errors. The benchmark measures whether
the agent **transfers to data it has not seen**.

Read this top to bottom and you — a human **or** an operator agent — can go from a
fresh clone to a running benchmark.

## The two roles
- **Operator** (you, or a master operator agent): sets up the machine, starts the eval
  API, launches the benchmark agents, resumes them when they stall, evaluates results.
  Your guides are this README, **`MASTER.md`** (the operator-agent playbook),
  **`RUNBOOK.md`** (per-harness launch commands), and `setup.sh`.
- **Benchmark agent**: the model under test. It reads **`CLAUDE.md`** (+ `AGENTS.md` /
  `GEMINI.md`) and must **not** read `do_not_read/`. You don't write its code — you
  launch it and it does the work.

## What's in here
| path | what |
|---|---|
| `CLAUDE.md` · `AGENTS.md` · `GEMINI.md` | the benchmark agent's contract (one per harness family) |
| `plan_v5.md` · `checklist_v5.md` | the task spec the agent implements |
| `MASTER.md` | the master operator agent's playbook: start → monitor → resume → evaluate |
| `evaluator/` | the sealed scoring API: `app.R` (plumber), `Dockerfile`, 6 dataset manifests |
| `operator/` | run tooling: auto-resume loops, results aggregator, eval-API watchdog (paths self-locate) |
| `setup.sh` · `smoke.sh` · `.env.example` | environment bootstrap, end-to-end check, config |
| `RUNBOOK.md` · `roster.yaml` · `task_prompt.template.txt` | per-harness launch commands, the model grid, the prompt template |

## Getting started — four steps

### 0. Prerequisites
- **R ≥ 4.x** with a C/Fortran toolchain (some packages compile from source).
- `curl` and `python3` (the operator loops use them).
- One or more **agent harness CLIs**, each with its own account / API key — see
  `RUNBOOK.md`: `claude` (Claude Code), `codex` (OpenAI Codex), `agy` (Antigravity),
  `openclaw`. These are the one piece that can't be scripted — they're your paid logins.

### 1. Install the environment
```bash
./setup.sh
```
Installs the R packages — the CRAN ones (`mgcv`, `HDtweedie`, `TDboost`, `tweedie`,
`statmod`, `dglm`, `cplm`, `plumber`, `jsonlite`, `yaml`) **and `CASdatasets`, which is
not on CRAN** (it feeds 5 of the 6 datasets, so it's pulled from its own repo). Then it
verifies every dataset loads. Want bit-for-bit reproducibility instead? Build the API
from `evaluator/Dockerfile`.

> **Why a script is needed at all:** the datasets aren't stored in this repo — they
> ship *inside* those R packages, so "get the data" = "install the packages." A plain
> `install.packages(...)` won't find `CASdatasets`; `setup.sh` knows where it lives.

### 2. Configure
```bash
cp .env.example .env       # then edit: the eval-API token + your harness API key(s)
```

### 3. Start the eval API and verify end-to-end
```bash
./setup.sh --start-api     # starts the scoring API on :8765
./smoke.sh                 # fits a trivial model on one dataset and scores it
```
`smoke.sh` prints a Gini value if the whole pipeline — data → fit → submit → score —
works. Green here means the box is ready.

### 4. Launch a benchmark run
Follow **`RUNBOOK.md`** for the exact per-harness command. In short: export the run
env, hand the agent the prompt from `task_prompt.template.txt`, and let it run (2–4 h
typical). A run is **complete when its `results/summary.csv` has all 24 cells
(6 datasets × 4 models) populated with a non-NA `mean_eval_gini`.**

## Notes
- **Secrets:** `evaluator/secrets/secrets.rds` is gitignored. The API runs without it
  (per-trial splits reseed randomly); provide it only to reproduce the *exact* original
  splits.
- **`do_not_read/`** holds operator analysis + results. It's off-limits to the
  *benchmark agent* (to prevent leakage), not to you as operator.
