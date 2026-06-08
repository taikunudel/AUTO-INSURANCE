# LLM Wiki Agent — Schema & Workflow Instructions

This wiki is maintained entirely by Gemini CLI. No API key or Python scripts needed — just open this repo with `gemini` and talk to it.

## How to Use

Describe what you want in plain English:
- *"Ingest this file: knowledge/raw/papers/my-paper.md"*
- *"What does the wiki say about transformer models?"*
- *"Check the wiki for orphan pages and contradictions"*
- *"Build the knowledge graph"*

Or use shorthand triggers:
- `ingest <file>` → runs the Ingest Workflow
- `query: <question>` → runs the Query Workflow
- `health` → runs the Health Workflow (fast, every session)
- `lint` → runs the Lint Workflow (expensive, periodic)
- `build graph` → runs the Graph Workflow

---

## Directory Layout

```
knowledge/         # All knowledge-base content lives here
  raw/             # Immutable source documents — never modify these
  wiki/            # Agent owns this layer entirely
    index.md       # Catalog of all pages — update on every ingest
    log.md         # Append-only chronological record
    gaps.md       # Append-only log of "no wiki support" moments — what to ingest next
    overview.md    # Living synthesis across all sources
    sources/       # One summary page per source document
    entities/      # People, companies, projects, products
    concepts/      # Ideas, frameworks, methods, theories
    syntheses/     # Saved query answers
  wiki-naive/      # Pre-regenerated comparison snapshot
  graph/           # Auto-generated graph data
  logs/            # Ingest run logs
  examples/        # Demo corpora (e.g. cjk-showcase/)
tools/             # Standalone Python scripts
  health.py        # Structural checks (deterministic, no LLM calls)
  lint.py          # Content quality checks (uses LLM for semantic analysis)
  build_graph.py   # Knowledge graph generation
```

---

## Page Format

Every wiki page uses this frontmatter:

```yaml
---
title: "Page Title"
type: source | entity | concept | synthesis
tags: []
sources: []
last_updated: YYYY-MM-DD
---
```

Use `[[PageName]]` wikilinks to link to other wiki pages.

---

## Ingest Workflow

Triggered by: *"ingest <file>"*

**Supported formats:** `.md` ingested directly. Non-markdown files (`.pdf`, `.docx`, `.pptx`, `.xlsx`, `.html`, `.txt`, `.csv`, `.json`, `.xml`, `.rst`, `.rtf`, `.epub`, `.ipynb`, `.yaml`, `.yml`, `.tsv`, `.wav`, `.mp3`) auto-converted via markitdown. Use `--no-convert` to skip.

1. Read the source document fully (auto-convert if non-markdown)
2. Read `knowledge/wiki/index.md` and `knowledge/wiki/overview.md` for current wiki context
3. Write `knowledge/wiki/sources/<slug>.md` (source page format below)
4. Update `knowledge/wiki/index.md` — add entry under Sources
5. Update `knowledge/wiki/overview.md` — revise synthesis if warranted
6. Update/create entity and concept pages
7. Flag contradictions with existing wiki content
8. Append to `knowledge/wiki/log.md`: `## [YYYY-MM-DD] ingest | <Title>`
9. **Post-ingest validation** — check for broken `[[wikilinks]]`, verify all new pages are in `index.md`, print a change summary

### Source Page Format

```markdown
---
title: "Source Title"
type: source
tags: []
date: YYYY-MM-DD
source_file: knowledge/raw/...
---

## Summary
2–4 sentence summary.

## Key Claims
- Claim 1

## Key Quotes
> "Quote here"

## Connections
- [[EntityName]] — how they relate

## Contradictions
- Contradicts [[OtherPage]] on: ...
```

### Domain-Specific Templates

If the source falls into a specific domain (e.g., personal diary, meeting notes), the agent should use a specialized template instead of the default generic one above:

#### Diary / Journal Template
```markdown
---
title: "YYYY-MM-DD Diary"
type: source
tags: [diary]
date: YYYY-MM-DD
---
## Event Summary
...
## Key Decisions
...
## Energy & Mood
...
## Connections
...
## Shifts & Contradictions
...
```

#### Meeting Notes Template
```markdown
---
title: "Meeting Title"
type: source
tags: [meeting]
date: YYYY-MM-DD
---
## Goal
...
## Key Discussions
...
## Decisions Made
...
## Action Items
...
```

---

## Query Workflow

Triggered by: *"query: <question>"*

1. Read `knowledge/wiki/index.md` — identify relevant pages
2. Read those pages
3. Synthesize answer with `[[PageName]]` citations
4. Offer to save as `knowledge/wiki/syntheses/<slug>.md`

---

## Lint Workflow

Triggered by: *"lint"*

Check for: orphan pages, broken links, contradictions, stale content, missing entity pages, sparse pages (< 2 outbound links), data gaps.

Graph-aware checks (require `graph.json`): hub stubs, fragile bridges, isolated communities.

---

## Health Workflow

Triggered by: *"health"*

Run: `python tools/health.py` (or `python tools/health.py --json` for machine-readable output)

Fast structural integrity checks — **zero LLM calls**, safe to run every session:
- **Empty / stub files** — pages with no content beyond frontmatter (rate-limit damage)
- **Index sync** — `knowledge/wiki/index.md` entries vs actual files on disk
- **Log coverage** — source pages missing a corresponding `ingest` entry in `knowledge/wiki/log.md`

Output a health report. Use `--save` to write to `knowledge/wiki/health-report.md`.

### Health vs Lint Boundary

| Dimension | `health` | `lint` |
|---|---|---|
| **Scope** | Structural integrity | Content quality |
| **LLM calls** | Zero | Yes (semantic analysis) |
| **Cost** | Free | Tokens |
| **Frequency** | Every session, before other work | Every 10-15 ingests |
| **Checks** | Empty files, index sync, log sync | Orphans, broken links, contradictions, gaps |
| **Tool** | `tools/health.py` | `tools/lint.py` |
| **Run order** | First (pre-flight) | After health passes |

> Run `health` first — linting an empty file wastes tokens.

---

## Graph Workflow

Triggered by: *"build graph"*

Try `python tools/build_graph.py --open` first. If unavailable, build graph.json and graph.html manually from wikilinks.

---

## Naming Conventions

- Source slugs: `kebab-case`
- Entity/Concept pages: `TitleCase.md`

## Log Format

`## [YYYY-MM-DD] <operation> | <title>`

Operations: `ingest`, `query`, `lint`, `graph`, `report`

---

## Graph Health Report

Triggered by: *"graph report"* or `python tools/build_graph.py --report`

Covers: health summary, orphan nodes, god nodes, fragile bridges, phantom hubs. Use `--save` to persist.

---

## Phase 3 Design Constraints (Auto-Linking — Open)

- Auto-linked edges start as `DRAFT`, require promotion gate validation
- Link density budget: ≥2 outbound wikilinks before promotion
- HG-WA-01: Graph layer MUST NOT auto-create pages from broken links
- HG-WA-02: New commands MUST NOT duplicate existing command coverage
