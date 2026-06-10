# Workspace Agent Instructions

This file is the workspace-level schema for any `AGENTS.md`-aware harness
(Codex, OpenCode, OpenClaw, etc.) operating inside this workspace. Claude
Code reads [`CLAUDE.md`](CLAUDE.md) and Gemini CLI reads
[`GEMINI.md`](GEMINI.md) — those files mirror the rules below so the same
workspace works under any harness.

---

## 🧪 This Branch Has No Knowledge Base

This is the **`no-wiki` arm** of a generalization benchmark. There is **no
local wiki or knowledge base** in this workspace — do not search for one,
and do not substitute external documentation lookups for it. Work from:

1. **Your own statistical and package knowledge** — model families, link
   functions, package calling conventions.
2. **The task spec** — `plan_v5.md` / `checklist_v5.md` define exactly what
   to build; they are known-good.
3. **Execution feedback** — R warnings, errors, and convergence messages
   are your primary debugging signal. Read them carefully: dataset-specific
   failure modes (divergence, smooth-basis limits, scaling issues) are
   discoverable from your own model output. When a fit fails or a metric
   looks wrong, diagnose from the output and fix the root cause — do not
   skip the combo.

If installed package signatures differ from what you expect, adapt to the
actual signature and log the discrepancy — do not halt.

---

## 📋 Task Trajectory — Log What You Do

When working on a modeling or coding task in this workspace, record what
you do as you do it so the work can be audited later.

**Where:** `audit/trajectories/<task-id>.jsonl` at the workspace root. Create
the `audit/trajectories/` folder if it doesn't exist. `<task-id>` is a short
slug — e.g. `auto-ins-2026-05-25` or whatever uniquely identifies this run.

**Format:** one JSON object per line, appended in real time (not batched at
the end — timestamps matter to the auditor). Required event types:

| event | required fields |
|---|---|
| `task_start` | `ts`, `task_id`, `goal`, `git_branch_start` |
| `decision` | `ts`, `task_id`, `summary`, `rationale` |
| `code_edit` | `ts`, `task_id`, `path`, `lines_added`, `lines_removed` |
| `code_run` | `ts`, `task_id`, `cmd`, `exit_code`, `summary` |
| `task_end` | `ts`, `task_id`, `summary`, `git_branch_end`, `git_sha_end` |

`ts` is ISO-8601 UTC (`2026-05-25T14:22:01Z`).

**Rules:**
- Append-only. Never edit or delete past entries.
- Emit each event immediately after the action it describes, not in a batch.
- Every substantive modeling decision gets a `decision` event with a real
  `rationale` (what evidence — spec, R output, diagnostics — drove it).

**Honesty:** the auditor cross-checks your trajectory against git history
(`git log -p`, file mtimes) and any harness-level tool logs. Omissions and
fabrications are detectable. Be complete — it's cheaper than getting caught.

---

## Workspace Conventions

- The `do_not_read/` folder is out of scope. Do not read, reference, or use
  files inside it as context.
- `MASTER.md`, `RUNBOOK.md`, and `operator/` are for the *operator* that
  launches benchmark runs — they are not part of your task. Your contract is
  this file plus the plan the operator hands you.
