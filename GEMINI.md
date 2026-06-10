# Workspace Instructions for Gemini CLI

This file is the workspace-level schema Gemini CLI reads on every session
in `/Users/theo/Downloads/auto-insurance/`. It mirrors
[`AGENTS.md`](AGENTS.md) (for Codex / OpenCode / OpenClaw) and
[`CLAUDE.md`](CLAUDE.md) (for Claude Code) so the same rules apply under
any harness.

The folder `knowledge-base/` is a cloned knowledge base
([taikunudel/llm-method-wiki](https://github.com/taikunudel/llm-method-wiki))
seeded with the auto-insurance / Tweedie corpus this project relies on.
Its own inside-the-repo `GEMINI.md` defines how to *maintain* the wiki
(ingest / query / lint / graph). The block below is what makes Gemini CLI
*consult* the wiki before writing modeling code in this workspace.

---

## 📚 Knowledge Base — Required

A local wiki at `knowledge-base/knowledge/wiki/` is part of your task context.
You **MUST** consult it before writing modeling, statistical, or
domain-specific code. Skipping it is not allowed.

**Required pre-task steps (in this order):**

1. Read `knowledge-base/knowledge/wiki/index.md` — the catalog of every page.
2. For each domain term in your task, grep the wiki:
   `grep -rli <term> knowledge-base/knowledge/wiki/`.
3. Read every matching page under `knowledge-base/knowledge/wiki/sources/`,
   `knowledge-base/knowledge/wiki/concepts/`, and
   `knowledge-base/knowledge/wiki/examples/`.
4. Before invoking any package call that has a corresponding wiki page,
   read that page's `Argument Quirks` / `Failure Modes` / `Code Example`
   sections.

**Citation is mandatory:**

- Every modeling or domain decision MUST cite the wiki page(s) that support
  it via `[[PageName]]` in code comments AND in your trajectory's `cites`
  array.
- Empty `cites` on a substantive decision = task failure.
- Prefer `knowledge-base/knowledge/wiki/examples/*.R` snippets — copy
  verbatim, then modify. Don't regenerate from training memory when an
  example exists.

**If the wiki has nothing relevant:** append an entry to
`knowledge-base/knowledge/wiki/gaps.md` describing what was missing (use
the format documented at the top of that file), then proceed, citing
"no wiki support". The wiki maintainer reviews `gaps.md` to decide what
to ingest next. (Optional additional: if trajectory logging is enabled,
also log a `gap_surfaced` event — see the Task Trajectory section
further down in this file.)

**Layout (so you know where to look):**

- `knowledge-base/knowledge/wiki/index.md`    — one-line catalog of every page (start here)
- `knowledge-base/knowledge/wiki/overview.md` — current synthesis across all sources
- `knowledge-base/knowledge/wiki/sources/`    — per-document summaries
- `knowledge-base/knowledge/wiki/concepts/`   — methods, frameworks, distributions
- `knowledge-base/knowledge/wiki/entities/`   — people, packages, organizations
- `knowledge-base/knowledge/wiki/examples/`   — runnable snippets per method

The wiki captures package-specific gotchas, paper-recommended hyperparameters,
and silent-failure modes that aren't in your training data. Reading it is the
difference between "code that runs" and "code that runs correctly." This is
not optional.

---

## 📋 Task Trajectory — Log What You Do

When working on a modeling, coding, or domain task that consults the wiki at
`knowledge-base/knowledge/wiki/`, record what you do as you do it so the work can be
audited later.

**Where:** `audit/trajectories/<task-id>.jsonl` at the workspace root. Create
the `audit/trajectories/` folder if it doesn't exist. `<task-id>` is a short
slug — e.g. `auto-ins-2026-05-25` or whatever uniquely identifies this run.

**Format:** one JSON object per line, appended in real time (not batched at
the end — timestamps matter to the auditor). Required event types:

| event | required fields |
|---|---|
| `task_start` | `ts`, `task_id`, `goal`, `wiki_root`, `git_branch_start` |
| `wiki_read` | `ts`, `task_id`, `page_id`, `bytes_read`, `sha256` |
| `decision` | `ts`, `task_id`, `summary`, `cites: [page_id,...]`, `rationale` |
| `code_edit` | `ts`, `task_id`, `path`, `lines_added`, `lines_removed`, `cites: [page_id,...]` |
| `code_run` | `ts`, `task_id`, `cmd`, `exit_code`, `summary` |
| `gap_surfaced` | `ts`, `task_id`, `concept`, `expected_page` |
| `task_end` | `ts`, `task_id`, `summary`, `git_branch_end`, `git_sha_end` |

`ts` is ISO-8601 UTC (`2026-05-25T14:22:01Z`). `page_id` is the path relative
to `knowledge/wiki/` (e.g. `concepts/TweedieDistribution.md`). `sha256` is the hash of
the page contents at the time you read it — the auditor recomputes from git
to detect fabricated reads.

**Rules:**
- Append-only. Never edit or delete past entries.
- Emit each event immediately after the action it describes, not in a batch.
- Every `decision` and `code_edit` MUST have a non-empty `cites` array if the
  wiki informed it. Empty cites on a substantive decision = faithfulness fail.
- Mirror every `Read` of a `knowledge/wiki/**` file as a `wiki_read` event.

**Honesty:** the auditor cross-checks your trajectory against git history
(`git log -p`, file mtimes) and any harness-level tool logs. Omissions and
fabrications are detectable. Be complete — it's cheaper than getting caught.

---

## Workspace Conventions

- The `do_not_read/` folder is out of scope. Do not read, reference, or use
  files inside it as context.
- `README.md`, `FINDINGS.md`, and `OPERATOR.md` are operator/human-facing
  documents about *completed* runs. Same rule as `do_not_read/`: do not read,
  reference, or use them as context for your task.
- The wiki repo at `knowledge-base/` has its own inside-the-repo schema
  files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`). Those govern wiki
  *maintenance* (ingest / lint / graph workflows) and only apply when an
  agent is working inside that subfolder. The block above is what governs
  every other task in this workspace.
