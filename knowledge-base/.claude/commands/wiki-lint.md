# /wiki-lint

**What it does:** Audits the wiki for quality issues — orphan pages, broken `[[wikilinks]]`, contradictions across pages, stale summaries, missing entity pages, and gaps in coverage. Uses semantic reasoning, so it consumes tokens; not a per-session check.

**When to use it:** Periodically (every 10–15 ingests). For fast, free structural checks every session, use `/wiki-health` (`python tools/health.py`) instead — see the Health vs Lint boundary in [CLAUDE.md](../../CLAUDE.md).

**Usage:** `/wiki-lint`

---

Follow the Lint Workflow defined in [CLAUDE.md](../../CLAUDE.md). Using the Grep, Glob, and Read tools, check for:

**Structural checks**
1. **Orphan pages** — wiki pages with no inbound `[[wikilinks]]` from other pages.
2. **Broken links** — `[[WikiLinks]]` pointing to pages that don't exist.
3. **Missing entity pages** — names referenced in 3+ pages but lacking their own page.

**Semantic checks**
4. **Contradictions** — claims that conflict between pages.
5. **Ungrounded contradictions** — `## Contradictions` entries missing a verbatim quote from one or both sides → fail.
6. **Stale summaries** — pages not updated after newer sources changed the picture.
7. **Data gaps** — important questions the wiki can't answer; suggest specific sources to find.

**Method/software coverage**
8. **Method pages without code** — pages tagged `[method]` or `[software]` lacking a fenced code block or `[[examples/...]]` wikilink → fail.
9. **Sources missing Canonical API** — source pages tagged `[method]` without a `## Canonical API` section → fail.
10. **Missing examples** — concept pages tagged `[method]` or `[software]` without a matching file under `knowledge/wiki/examples/` → fail.
11. **Stub concept pages** — concept pages under 500 characters of body content with no required sections → fail.

Output a structured markdown lint report. Ask if the user wants it saved to `knowledge/wiki/lint-report.md`.

Append to `knowledge/wiki/log.md`: `## [YYYY-MM-DD] lint | Wiki health check`.
