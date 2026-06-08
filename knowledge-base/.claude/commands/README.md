# Claude Code slash commands

These four files define the `/wiki-*` slash commands that Claude Code exposes when you open this repo. They are intentionally thin: each one names the workflow it invokes; the full step-by-step definitions live in [`CLAUDE.md`](../../CLAUDE.md) at the repo root.

You can invoke them in two ways:

- Type the slash command: `/wiki-ingest knowledge/raw/my-paper.md`
- Or just say what you want: *"ingest knowledge/raw/my-paper.md"*

Claude Code reads `CLAUDE.md` automatically on every session, so both forms route to the same workflow.

## Commands

| Command | What it does | Example |
|---|---|---|
| [`/wiki-ingest`](wiki-ingest.md) | Process a file from `knowledge/raw/` into the wiki — write a source page, update `index.md` / `overview.md`, create or merge concept and entity pages, append to `log.md`. | `/wiki-ingest knowledge/raw/papers/qian-2016-hdtweedie.md` |
| [`/wiki-query`](wiki-query.md) | Answer a question against the wiki with `[[PageName]]` citations. Optionally save the answer as a synthesis page. | `/wiki-query what are the failure modes of HDtweedie?` |
| [`/wiki-lint`](wiki-lint.md) | Quality audit — orphan pages, broken links, contradictions, stale summaries, gaps. Expensive; run periodically. | `/wiki-lint` |
| [`/wiki-graph`](wiki-graph.md) | Build the `[[wikilink]]` graph and write `knowledge/graph/graph.json` + an interactive `knowledge/graph/graph.html`. | `/wiki-graph` |

`/wiki-health` (fast structural checks via `tools/health.py`) is documented in [CLAUDE.md](../../CLAUDE.md) but does not yet have a dedicated slash-command file here.

## See also

- [Project README](../../README.md) — what this wiki is and how to start using it.
- [CLAUDE.md](../../CLAUDE.md) — full schema, page templates, and workflow definitions.
