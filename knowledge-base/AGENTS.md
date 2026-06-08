# LLM Wiki Agent — Schema & Workflow Instructions

This wiki is maintained entirely by your coding agent. No API key or Python scripts needed — just open this repo in Codex, OpenCode, or any agent that reads this file, and talk to it.

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
    examples/      # Verified runnable snippets — one file per method/software concept
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
type: source | entity | concept | synthesis | diagnostic
tags: []
sources: []       # list of source slugs that inform this page
last_updated: YYYY-MM-DD
---
```

Use `[[PageName]]` wikilinks to link to other wiki pages.

---

## Ingest Workflow

Triggered by: *"ingest <file>"*

**Supported formats:** Markdown (`.md`) is ingested directly. Non-markdown files (`.pdf`, `.docx`, `.pptx`, `.xlsx`, `.html`, `.txt`, `.csv`, `.json`, `.xml`, `.rst`, `.rtf`, `.epub`, `.ipynb`, `.yaml`, `.yml`, `.tsv`, `.wav`, `.mp3`) are auto-converted to markdown via [markitdown](https://github.com/microsoft/markitdown) before ingestion. Use `--no-convert` to skip auto-conversion.

Steps (in order):
1. Read the source document fully (auto-convert if non-markdown)
2. **Build wiki context** — do not write anything until you have read the existing pages this ingest will touch:
   a. Read `knowledge/wiki/index.md` and `knowledge/wiki/overview.md`
   b. Use Grep to find any token in the source that matches a filename under `knowledge/wiki/concepts/` or `knowledge/wiki/entities/`
   c. Read each matching page in full. **Never overwrite a page you have not read.**
3. Decide which source template applies (Generic / Diary / Meeting / **Method-Software**) and write `knowledge/wiki/sources/<slug>.md`
4. Update `knowledge/wiki/index.md` — add entry under Sources section
5. Update `knowledge/wiki/overview.md` — revise synthesis if warranted
6. Update or create entity pages for key people, companies, projects mentioned — merge with the existing page, do not overwrite
7. Update or create concept pages for key ideas, methods, frameworks. Pick the **Method / Software** or **Domain** concept template based on the concept's flavor. Merge with the existing page; never replace verified content with a shorter summary.
8. **For sources tagged `[method]` or `[software]`:** write or update `knowledge/wiki/examples/<slug>.R` (or `.py`) — a minimal *verified* call against the dataset the paper actually uses. If you cannot verify the snippet, stub it with a `# UNVERIFIED` header and surface this in the change summary.
9. Flag any contradictions with existing wiki content. Each contradiction MUST cite a verbatim quote from both sides — ungrounded contradictions are forbidden.
10. Append to `knowledge/wiki/log.md`: `## [YYYY-MM-DD] ingest | <Title>`
11. **Post-ingest validation** — check for broken `[[wikilinks]]`, verify every new method/software concept has a matching `knowledge/wiki/examples/` file, verify all new pages are in `index.md`, print a change summary

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
- Claim 2

## Key Quotes
> "Quote here" — context

## Connections
- [[EntityName]] — how they relate
- [[ConceptName]] — how it connects

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

#### Method / Software Paper Template

Use when the source introduces, implements, or benchmarks a statistical model, algorithm, or software package the agent will later be asked to *call*. This is the template that turns book-report summaries into operational knowledge.

```markdown
---
title: "Paper Title"
type: source
tags: [method, <package-name>]
date: YYYY-MM-DD
source_file: knowledge/raw/...
---
## Summary
2–4 sentence summary.

## Canonical API
The minimal call as actually written in the paper or package documentation. Real argument names, no pseudo-code.
​```R
fit  <- pkg::fn(x, y, p = 1.5, alpha = 0.7, nfolds = 5)
pred <- predict(fit, newx = x_test, s = "lambda.min", type = "response")
​```

## Key Hyperparameters
| Name | Role | Default | Paper-recommended | Sensible grid |
|---|---|---|---|---|
| p | variance power | 1.5 | profile via `tweedie.profile` | [1.1, 1.9] |
| alpha | L1/L2 mix | 1 | 0.7 for correlated predictors | {0.5, 0.7, 1.0} |

## Argument Quirks
- Pre-conditions on input shape (e.g., `x` must be numeric matrix, no intercept column)
- Required predict-time args that have silent-failure defaults (e.g., `s = "lambda.min"`)
- Offsets, weights, exposure conventions

## Failure Modes
- Silent crashes (unseen factor levels, NA handling, degenerate splits)
- Numerical instability regions (e.g., Tweedie density near `p = 1` or `p = 2`)
- Convergence issues and how the paper handles them

## Code Example
Verified runnable snippet lives at `[[examples/<slug>]]`. Do not duplicate the snippet here — link to it.

## Domain Pitfalls
Knowledge the paper assumes the reader has but does not state explicitly. For insurance/actuarial work: exposure handling, zero-inflation behavior, treatment of unseen factor levels, why log-transforms are applied to specific variables.

## Connections
- [[ConceptName]] — how it connects

## Contradictions
- Contradicts [[OtherPage]] on: "<verbatim quote from other page>" vs "<verbatim quote from this source>"
```

---

## Concept Page Format

Concept pages declare a flavor via `tags`. The flavor determines required sections. Stubs (a single paragraph with no required sections) are no longer acceptable — lint will flag them.

### Method / Software Concept

`tags: [method]` or `tags: [software]`

```markdown
---
title: "Concept Name"
type: concept
tags: [method]
sources: [source-slug-1, source-slug-2]
last_updated: YYYY-MM-DD
---
## Definition
1–2 sentences. What it is, not why it exists.

## When to Use
- Conditions under which this method is preferred
- Conditions under which it is NOT preferred (or a sibling method wins)

## Canonical Call
Minimal call signature, matching the source's Canonical API. Wikilink to `[[examples/<slug>]]` for the runnable end-to-end snippet.

## Key Hyperparameters
Same table format as the source template's Key Hyperparameters.

## Common Pitfalls
- Things that silently produce wrong answers
- Things that crash but with unhelpful messages
- Defaults that match the paper but disagree with software defaults

## Sources
- [[source-slug]] — what this source contributes
```

### Domain Concept

`tags: [domain]` plus a domain tag (e.g. `[domain, actuarial]`)

```markdown
---
title: "Concept Name"
type: concept
tags: [domain, actuarial]
sources: [...]
last_updated: YYYY-MM-DD
---
## Definition
1–2 sentences.

## Why It Matters in Practice
Concrete consequences if mishandled — what breaks, what gets miscalibrated, what regulator complains.

## How to Handle in Code
Specific transformations, guards, or patterns. Cite `[[examples/...]]` where applicable.

## Common Mistakes
- ...

## Sources
- [[...]] — what this source contributes
```

### Diagnostic Concept

`type: diagnostic` — captures evaluation, calibration, and sanity-check procedures. Pages like `GiniSanityChecks`, `CalibrationPlots`, `LeakageAudit`.

```markdown
---
title: "Diagnostic Name"
type: diagnostic
tags: [evaluation]
sources: [...]
last_updated: YYYY-MM-DD
---
## What It Checks
The single failure mode this diagnostic catches.

## Procedure
Step-by-step. Include a runnable snippet (or wikilink to `[[examples/...]]`).

## Pass / Fail Thresholds
Numeric ranges. E.g., "Gini > 0.6 on AutoClaim → leakage audit required."

## When to Run
Per-fit, per-trial, before reporting results, etc.
```

---

## Query Workflow

Triggered by: *"query: <question>"*

Steps:
1. Read `knowledge/wiki/index.md` to identify relevant pages
2. Grep the question for any token matching a `knowledge/wiki/concepts/`, `knowledge/wiki/entities/`, or `knowledge/wiki/examples/` filename — read every match (index summaries are lossy by design)
3. Read those pages
4. Synthesize an answer with inline citations as `[[PageName]]` wikilinks
5. Ask the user if they want the answer filed as `knowledge/wiki/syntheses/<slug>.md`

---

## Use Workflow

Triggered by: *any modeling, coding, or domain task that the wiki could inform.* This is the workflow the agent applies **on its own** before producing domain output — not user-invoked. Without it, the wiki is write-only.

The wiki is intentionally small. Reading all of it is cheap; guessing the API is expensive.

Steps:
1. List `knowledge/wiki/concepts/`, `knowledge/wiki/sources/`, `knowledge/wiki/examples/`
2. Read every page whose title names a concept, package, method, or term appearing in the task
3. If the task touches a `[method]` or `[software]` concept that has **no** `knowledge/wiki/examples/<slug>` file, surface the gap to the user **before** writing code. Do NOT invent the API.
4. Cite the originating wiki page(s) inline in code comments where a non-obvious choice is made (e.g., `# variance power per [[TweedieDistribution]]`)
5. After the task, if the work surfaced a gap (a substantive decision made with no wiki support), **append an entry to `knowledge/wiki/gaps.md`** with the format documented at the top of that file. Also surface contradictions or new pitfalls and propose a wiki update before closing out.

---

## Lint Workflow

Triggered by: *"lint"*

Check for:
- **Orphan pages** — wiki pages with no inbound `[[links]]` from other pages
- **Broken links** — `[[WikiLinks]]` pointing to pages that don't exist
- **Contradictions** — claims that conflict across pages
- **Ungrounded contradictions** — `## Contradictions` entries missing a verbatim quote from one or both sides → fail
- **Stale summaries** — pages not updated after newer sources
- **Missing entity pages** — entities mentioned in 3+ pages but lacking their own page
- **Sparse pages** — pages with fewer than 2 outbound `[[wikilinks]]` (link density budget)
- **Data gaps** — questions the wiki can't answer; suggest new sources
- **Method pages without code** — pages tagged `[method]` or `[software]` (source or concept) lacking a fenced code block or a `[[examples/...]]` wikilink → fail
- **Sources missing Canonical API** — source pages tagged `[method]` without a `## Canonical API` section → fail
- **Missing examples** — concept pages tagged `[method]` or `[software]` without a matching file under `knowledge/wiki/examples/` → fail
- **Stub concept pages** — concept pages under 500 characters of body content with no required sections from the Concept Page Format → fail

Graph-aware checks (require `graph.json` from `build graph`):
- **Hub stubs** — god nodes (degree > μ+2σ) with thin content (< 500 chars)
- **Fragile bridges** — community pairs connected by only 1 edge
- **Isolated communities** — clusters with zero external connections

Output a lint report and ask if the user wants it saved to `knowledge/wiki/lint-report.md`.

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

First try: `python tools/build_graph.py --open`

If Python/deps unavailable, build manually:
1. Search for all `[[wikilinks]]` across wiki pages
2. Build nodes (one per page) and edges (one per link)
3. Infer implicit relationships not captured by wikilinks — tag `INFERRED` with confidence score; low confidence → `AMBIGUOUS`
4. Write `knowledge/graph/graph.json` with `{nodes, edges, built: date}`
5. Write `knowledge/graph/graph.html` as a self-contained vis.js visualization

---

## Naming Conventions

- Source slugs: `kebab-case` matching source filename
- Entity pages: `TitleCase.md` (e.g. `OpenAI.md`, `SamAltman.md`)
- Concept pages: `TitleCase.md` (e.g. `ReinforcementLearning.md`, `RAG.md`)

## Index Format

```markdown
# Wiki Index

## Overview
- [Overview](overview.md) — living synthesis

## Sources
- [Source Title](sources/slug.md) — one-line summary

## Entities
- [Entity Name](entities/EntityName.md) — one-line description

## Concepts
- [Concept Name](concepts/ConceptName.md) — one-line description

## Syntheses
- [Analysis Title](syntheses/slug.md) — what question it answers
```

## Log Format

`## [YYYY-MM-DD] <operation> | <title>`

Operations: `ingest`, `query`, `health`, `lint`, `graph`, `report`

---

## Graph Health Report

Triggered by: *"graph report"* or `python tools/build_graph.py --report`

The `--report` flag generates a structured graph health report covering:
- **Health summary** — edges/node ratio, orphan %, community count, link density
- **Orphan nodes** — pages with zero graph connections
- **God nodes** — hub pages with degree > μ+2σ (disproportionate connectivity)
- **Fragile bridges** — community pairs connected by only 1 edge
- **Phantom hubs** — `[[wikilinks]]` referenced by 2+ existing pages but pointing to non-existent pages (page creation signals)

Use `--save` to write the report to `knowledge/graph/graph-report.md`.

---

## Phase 3 Design Constraints (Auto-Linking — Open)

Phase 3 proposes automatic `[[wikilink]]` insertion based on graph analysis. The following hard rules apply:

### Promotion Gate: `draft → stable`
- Auto-linked edges start as `DRAFT` (visible in graph, not written to page body)
- A dedicated `promote` pass validates source grounding + consistency
- Only edges that pass get materialized as `[[wikilinks]]` in the page
- **Link density budget**: a page must have ≥2 outbound wikilinks before promotion

### Hard Rules
| ID | Rule | Rationale |
|---|---|---|
| HG-WA-01 | Graph layer MUST NOT auto-create pages from broken links — report only | LLM ingest produces hallucinated wikilinks; auto-creating amplifies noise |
| HG-WA-02 | New slash commands MUST NOT duplicate existing command coverage | Prevents user confusion; merge into existing commands instead |
