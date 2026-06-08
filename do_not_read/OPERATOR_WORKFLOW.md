# Operator Workflow — v5 Benchmark (human reference)

> Lives in `do_not_read/` so the benchmark agents never see it. Mirror of the operator
> memory playbook (`~/.claude/projects/-Users-theo-Downloads-auto-insurance/memory/project_v5_execution_playbook.md`).
> Last ran end-to-end 2026-06-05 (run1 / wiki0531). Lessons through 2026-06-05 folded in.

## Role — OPERATOR ONLY (do NOT help the agents)
Helping an agent with its modeling/code contaminates the benchmark. Duties only:
1. **Start them correctly** — right model string (SMOKE-TESTED, §1.5), thinking level, wiki version, env, EXACT folder name.
2. **Wait** for completion without interfering.
3. **Rescue logs** — copy the harness session JSONL into `logs/` if the agent didn't. The ONLY assist.
4. **Analyze ONLY on the user's explicit instruction** — never freelance.

Agents stay blind: model/harness/thinking/wiki-version are operator metadata.

## ⛔ STANDING RULE — OpenRouter ALWAYS, Google NEVER
**(user, emphatic, repeated 2026-06-05)** For every openclaw/OpenRouter model, route via **OpenRouter**, **never** Google (`google-vertex`/`google-ai-studio`). All `google-vertex` provider pins in `~/.openclaw/openclaw.json` were replaced with non-google routing. Never re-add one. Smoke-test must show a non-Google `winnerProvider`.

## 0. Prereqs
- **Eval API — CHECK FIRST:** `curl -s localhost:8765/healthz` → `{"ok":true}` means it's already up (host `Rscript app.R` plumber); **do NOT start another**. If down:
  `cd /Users/theo/claude/eval-api && EVAL_ADMIN_TOKEN=test-token-12345 PORT=8765 HOST=0.0.0.0 Rscript app.R &`
- **Metric column is `mean_eval_gini`** (0–1 fraction) — NOT `mean_test_gini` (old name).
- **Wiki:** live `llm-wiki-agent/knowledge/wiki/` = **0531** (the only arm; never 0530).
- **Timezone trap:** machine local = **EDT (UTC−4)**. `ls`/`find -printf`/`stat` print LOCAL time; `date -u` is UTC; folder names + the run use UTC. Don't compare a UTC string against `find -newermt` (it parses local).

## 1. Launch one agent — per harness (env + nohup-detached, cd project root, agent makes its folder)
Env each run: `EVAL_API_URL=http://localhost:8765  RUN_INDEX=<X>  WIKI_VERSION=0531  THINKING_LEVEL=<lvl>`.
**Launch via `nohup … &`, never a harness background-task wrapper (those get killed).** SMOKE-TEST the string first (§1.5).

- **claudecode** — `claude -p "<prompt>" --model <str> --effort max --dangerously-skip-permissions --output-format json`
  - Binary `/Users/theo/.local/bin/claude` (v2.1.161). `--effort` IS a real flag. Strings verified: `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5`. The "no stdin data in 3s" warning is benign (it took the prompt from `-p`).
- **codex** — `codex exec "<prompt>" -C <ws> -m <str> -c model_reasoning_effort=xhigh --dangerously-bypass-approvals-and-sandbox`
  - `gpt-5.4`, `gpt-5.5` work on the ChatGPT-account login. **`gpt-5.3` AND `gpt-5.3-codex` → HTTP 400 "not supported when using Codex with a ChatGPT account"** — an *auth gate*, not a name; the `-codex` suffix and config.toml-pin both fail the same way. To run 5.3 you need API-key auth (`codex login --with-api-key`; current `auth.json` has only ChatGPT tokens, no `OPENAI_API_KEY`).
- **antigravity** — *this IS the "gemini" harness. The gemini CLI is DEPRECATED/replaced by antigravity (`agy`). ALL gemini-family agents run via `agy`.*
  `agy -p "<prompt>" --model "<Display Name>" --dangerously-skip-permissions --print-timeout 4h`
  - `agy models` lists exact names: `"Gemini 3.1 Pro (High)"`, `"Gemini 3.5 Flash (High)"` (also Claude Sonnet/Opus 4.6 (Thinking), GPT-OSS 120B).
  - **`--print-timeout` defaults to 5m — MUST raise to 4h.** Default model lives in `~/.gemini/antigravity-cli/settings.json`. Conversations under `~/.gemini/antigravity-cli/conversations/`.
  - Gemini 3.5 Flash is **404 on the gemini CLI** — antigravity-only. agy is slow to create its folder (~2 min).
- **openclaw** — `openclaw agent --agent main --session-key agent:main:<key> --model <provider/model> --thinking <lvl> --timeout 14400 --message "<prompt>" --json`
  - `--agent main` required; **`--timeout 14400`** (default 600s kills it); gateway path, not `--local`.
  - **Model MUST be in the allowlist** `~/.openclaw/openclaw.json` → `agents.defaults.models` (else `Model override "…" is not allowed for agent "main"`). The `:free` suffix is a **separate key** from the non-free. Some entries are pinned to `params.provider.order:["google-vertex"]` = **routes via Google Vertex**. To honour "OpenRouter, not Google": register the entry with **no** google pin, or pin to non-google providers (`deepinfra`/`dekallm`/`novita`, `allow_fallbacks:false`). **Config edits are picked up WITHOUT a gateway restart.**
  - OpenRouter **`:free` tier = instant "API rate limit reached"** → not viable for a 240-trial run; use a cheap paid non-google provider (~$0.07/M, run << $1). List providers: `curl https://openrouter.ai/api/v1/models/<id>/endpoints`.
  - openclaw **ALLOWS concurrent `--agent main` sessions** (different session-keys). Slow to first-trial (writes the whole orchestrator before trial 1).

Folder name (EXACT): `run-<harness>-<model>-<thinking>-run<X>-wiki<MMDD>-<YYYYMMDD-HHMMSS>` (lowercase, hyphens, UTC).

## 1.5 SMOKE-TEST every model string BEFORE the full launch — HARD LESSON
Launching unverified strings cost real failures (gpt-5.3, gemini-3.5-flash-on-CLI, gemma-:free). Always:
- **openclaw:** `openclaw agent --agent main --session-key agent:main:smoke-$$ --model <str> --message "Reply OK" --json` → require `result=success`, `winnerModel`=expected, **`fallbackUsed=false`** (a fallback or different winnerModel = wrong route / not really that model).
- **claude:** `claude -p "say OK" --model <str> --dangerously-skip-permissions` → "OK".
- **antigravity:** `agy models` to confirm the display name, then a one-line `agy -p`.
- **codex:** tiny `codex exec "Reply OK" -m <str> …` — catches the ChatGPT-auth 400s.

## 2. Document each launch (into the run folder)
`operator_launch.md` (env + command + model string + smoke result + any history), `operator_prompt.txt`, `operator_launch.log`.
Keep the **bootstrap prompt identical across harnesses** (experiment fairness — no per-harness anti-early-stop nudges).

## 3. Verify early (~75 s; agy/openclaw can take ~2 min to make the folder) then leave it alone
Correct folder name · agent reading the wiki · API up · no stray writes to project root. Then don't touch its work.

## 4. Completion — VERIFY coverage, never trust the agent's "done"
- COMPLETE only when `results/summary.csv` has all **24 combos** (6 datasets × 4 models) with **`mean_eval_gini`** populated and plausible (~0.16–0.85).
  - Datasets: `ausprivauto, auto_insurance, bemtpl97, fremtpl2, sgautonb, swautoins`.
  - Models: `tweedie_gam, grplasso, grpnet, tdboost` (Tweedie **GLM dropped** in v5). 240 trials = 24 × 10.
- **NEVER mark finished off the agent's self-report.** Audit: `#datasets, #models, #combos, gini populated`. A summary with 24 combos but a dataset at <10 trials = **truncated** (interrupted mid-dataset), not fully done.
- **Log rescue** (only assist): claude `~/.claude/projects/<enc-cwd>/<SID>.jsonl`; codex `$CODEX_HOME/sessions/**/rollout-*<SID>*.jsonl`; openclaw `~/.openclaw/agents/<id>/sessions/`; antigravity `~/.gemini/antigravity-cli/conversations/`.

## 5. Resume — ONLY external stops, NEVER self-stops (user rule)
**Resume a run ONLY if it was stopped EXTERNALLY (kill / crash / network). If the AGENT itself decided it was done on an incomplete run, do NOT resume — that's a measured faithfulness failure and resuming erases the signal.**
- **Self-stop** signature: session/turn ended clean (`stopReason=stop`, status `done`) + incomplete coverage → leave it (e.g. or-gemini35flash declared done at 1/6 datasets).
- **External** signature: orchestrator log ends mid-trial, empty subprocess log, no completion line → resume (e.g. gpt5.4/gpt5.5 codex both died ~00:46 UTC mid-trial — looked like a system/harness event).
- Mechanism = **message the AGENT to check its own progress and continue** (never operator-run its orchestrator):
  - codex: `codex exec resume <SID> "<msg>" -m <model> -c model_reasoning_effort=xhigh --dangerously-bypass-approvals-and-sandbox` (**NO `-C`**).
    - **Pin `-m <model>`** so `config.toml`'s default (gpt-5.5) can't leak into e.g. a gpt-5.4 resume.
    - **zsh gotcha:** pass flags as LITERAL tokens, NOT through an unquoted `$VAR` — zsh doesn't word-split, so `$MFLAG="-m gpt-5.4 -c …"` arrives as ONE mangled arg → 400. (Same trap bit a status loop; use `read`/arrays or literals.)
    - Find the session: `grep -l <folder-name> ~/.codex/sessions/**/rollout-*.jsonl`; the UUID is in the filename (filename time is LOCAL/EDT).
  - claude `claude --resume <SID> -p "<msg>" …`; antigravity `agy -c` / `agy --conversation <id>`; openclaw re-message the same `--session-key`.
  - `<msg>` = "You were interrupted; read results/summary.csv for progress; if every dataset×model has mean_eval_gini, confirm done; else continue to completion; do NOT restart or wipe completed work."
- **Back up `results/` → `operator_results_backup_preresume/` first.** A seed-deterministic run that wipes+redoes still yields identical numbers, so completion is what matters.

## 6. Roster — run1/wiki0531 (confirm `<str>` + SMOKE per run)
| # | harness | model-id | `<str>` / display | thinking | notes |
|---|---|---|---|---|---|
| 1–3 | claudecode | opus47 / sonnet46 / haiku45 | claude-opus-4-7 / claude-sonnet-4-6 / claude-haiku-4-5 | --effort max | all 3 smoke-OK |
| 4 | codex | gpt5.3 | gpt-5.3 | xhigh | **BLOCKED** on ChatGPT-account codex (400); needs API-key |
| 5–6 | codex | gpt5.4 / gpt5.5 | gpt-5.4 / gpt-5.5 | xhigh | OK |
| 7–8 | **antigravity** | gemini3.1pro / gemini35flash | "Gemini 3.1 Pro (High)" / "Gemini 3.5 Flash (High)" | high | via `agy`, NOT gemini CLI |
| 9 | openclaw | gpt5.5 | openai/gpt-5.5 | xhigh | |
| 10 | openclaw | gemini31pro | google/gemini-3.1-pro-preview | high | **CANCELLED** per user |
| 11 | openclaw | or-gemini31pro | openrouter/google/gemini-3.1-pro-preview | high | smoke-OK |
| 12–15 | openclaw | glm46 / glm51 / or-glm47 / or-glm51 | zai/glm-4.6 · zai/glm-5.1 · openrouter/z-ai/glm-4.7 · openrouter/z-ai/glm-5.1 | high | not started |
| 16 | openclaw | or-gemma4 | openrouter/google/gemma-4-26b-a4b-it | high | **must pin non-google provider** (default entry was google-vertex; `:free` rate-limited) |
| +x | openclaw | or-gemini35flash | openrouter/google/gemini-3.5-flash | high | off-grid extra; self-stopped 1/6 → not resumed |

Seed = `1000*RUN_INDEX + trial`; **run1 → seeds 1001–1010, identical for ALL run1 agents** (shared seed by design; API splits are separate).

## 7. Scheduling (provider-quota staggered; 0531 only)
Auto-scheduler `/Users/theo/claude/auto-ins-scheduler/scheduler.py` (detached). Monitor `tail -f .../scheduler.log`; stop `pkill -f scheduler.py`; adjust = edit + relaunch `nohup python3 scheduler.py &`.
- On RESTART, remove already-fired batches from the script or it re-fires/duplicates them (no persistent `done`).
- #10 cancelled; Batch4 trimmed to #9 + #11; deps still reference dead #4 + old #8 name (dep-locked until repointed).

## 8. Session lessons quick-ref (2026-06-05)
- "gemini" harness = **antigravity (`agy`)**; gemini CLI is dead. `agy --model` per-run; `agy models` lists names; `--print-timeout 4h`.
- codex **gpt-5.3(-codex) blocked** on ChatGPT-auth (400) — needs API key.
- **SMOKE-TEST every string** before launch (fallbackUsed=false, winnerModel matches).
- claude **`--effort` is valid** (v2.1.161); opus/sonnet/haiku strings all OK.
- openclaw **allowlist** in openclaw.json; `:free` ≠ paid key; **google-vertex provider pins** → set non-google providers for "OpenRouter not Google"; OpenRouter `:free` = rate-limited.
- Metric = **`mean_eval_gini`** (not test).
- **zsh doesn't word-split unquoted `$VAR`** → pass multi-flag args as literals.
- Timezone: machine = EDT (UTC−4); `ls`/`find`/`stat` local, `date -u` UTC; folders use UTC.
- Long codex runs get **externally killed** (saw ~00:46 UTC simultaneous death of both) — nohup helps but won't stop system-level kills; resume them.
- **Completion = summary.csv coverage (24 combos, mean_eval_gini), never the agent's "done."**
