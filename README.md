# auto-insurance — LLM-agent generalization benchmark

AI coding agents autonomously write R to fit four Tweedie-family models
(`tweedie_gam`, `grplasso`, `grpnet`, `tdboost`) across six held-out insurance
datasets, scored by Gini via a local eval API. The agent consults a local
knowledge wiki (`knowledge-base/`) but must discover dataset-specific fixes
itself — the wiki deliberately omits them (see the leakage-quarantine note in
`CLAUDE.md`). The benchmark measures whether agent + wiki transfer to data they
have not seen.

## Layout
| path | what |
|---|---|
| `CLAUDE.md` · `AGENTS.md` · `GEMINI.md` | workspace contract each harness reads — **must stay at repo root** |
| `plan_v5.md` · `checklist_v5.md` | task spec |
| `knowledge-base/` | the wiki the agent consults (`knowledge/wiki/`); snapshot **0531** — see `WIKI_VERSION.txt` |
| `evaluator/` | scoring API: `app.R` (plumber), `Dockerfile`, `datasets/` (6 manifests) |
| `operator/` | run tooling: `auto-resume*.py`, `eval-api-watchdog.sh` — paths self-locate from the repo root |

Run artifacts, `do_not_read/`, `paper/`, and all secrets are gitignored.

## Setup (remote)
```bash
git clone <repo> auto-insurance && cd auto-insurance
export WORKSPACE="$PWD"             # operator/ tools default to this anyway

# 1. eval API — R deps, then run (or use evaluator/Dockerfile)
Rscript -e 'install.packages(c("cplm","jsonlite","plumber","yaml"))'
# provision the eval secret out-of-band (NOT in git): evaluator/secrets/secrets.rds
(cd evaluator && EVAL_ADMIN_TOKEN=<token> PORT=8765 HOST=0.0.0.0 Rscript app.R &)
curl -s localhost:8765/healthz       # -> {"ok":true}

# 2. launch an agent run (claudecode example); it reads knowledge-base/ and submits to the API
EVAL_API_URL=http://localhost:8765 RUN_INDEX=1 WIKI_VERSION=0531 \
  claude -p "<task prompt>" --model <model> --dangerously-skip-permissions --output-format json
```

## Notes
- **Secrets:** `evaluator/secrets/` is excluded from git — copy `secrets.rds` to the remote separately.
- **Wiki version:** ships snapshot **0531**. Full history + the `0530` snapshot live in the source wiki repo (tags `wiki-0530` / `wiki-0531`), intentionally not vendored here.
- **Keep this repo private** — `evaluator/datasets/` are the held-out benchmark manifests.
