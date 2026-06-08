# Operator TODO — v5 benchmark (do_not_read; operator-only)

## GLM roster (openclaw / `zai`) — user-narrowed 2026-06-06
**ONLY these 4 GLMs are in scope. OLDER MODELS NEVER INCLUDED** — no `glm-4.6`/glm46,
no glm-4.5*, glm-4*, glm-z1*, glm-3, and no vision (`*v`) variants. They are dropped
from the roster/status table entirely.

- [x] `glm-5.1`  (`zai/glm-5.1`)       — DONE: ran as glm51, run1 = 240/24 ✅
- [ ] `glm-5`        (`zai/glm-5`)        — TODO (run later, not now)
- [ ] `glm-5-turbo`  (`zai/glm-5-turbo`)  — TODO (run later, not now)
- [ ] `glm-4.7`      (`zai/glm-4.7`)      — TODO (run later, not now)

Launch when told (zai rejects `--thinking high` → use `on`):
`openclaw agent --agent main --session-key agent:main:<id>-run1 --model zai/glm-<X> --thinking on --timeout 14400 --message "<prompt>" --json`
folder `run-openclaw-<id>-high-run1-wiki0531-<UTC>`.

## Other pending
- openclaw **gpt5.4** (openai) — launched 2026-06-06; arm auto-resume (same nested-codex ~10-min timeout as gpt5.5); shares the ChatGPT/codex subscription with gpt5.5 (watch for contention).
- openclaw **gpt5.5** (openai) — resuming via `~/claude/auto-resume-gpt55.py` loop (was 52 trials, status=running).
- **run2** (RUN_INDEX=2, seeds 2001–2010) for the finished roster — not started.
