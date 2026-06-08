# /wiki-ingest

**What it does:** Processes a source document from `knowledge/raw/` into the wiki — writes a `knowledge/wiki/sources/<slug>.md`, updates `knowledge/wiki/index.md` and `knowledge/wiki/overview.md`, creates or merges any concept and entity pages it mentions, and appends an entry to `knowledge/wiki/log.md`.

**When to use it:** After you drop a new file into `knowledge/raw/` (paper, article, notes, etc.) and want it integrated into the wiki.

**Usage:** `/wiki-ingest <path-in-raw>` — e.g. `/wiki-ingest knowledge/raw/articles/my-article.md`

Markdown is ingested directly. Other formats (`.pdf`, `.docx`, `.pptx`, `.xlsx`, `.html`, `.txt`, `.csv`, `.json`, `.xml`, `.rst`, `.rtf`, `.epub`, `.ipynb`, `.yaml`, `.tsv`, `.wav`, `.mp3`) auto-convert via [markitdown](https://github.com/microsoft/markitdown) before ingestion.

---

Follow the Ingest Workflow defined in [CLAUDE.md](../../CLAUDE.md):

1. Read the source file at the given path (auto-convert if non-markdown).
2. Read `knowledge/wiki/index.md` and `knowledge/wiki/overview.md` for current context.
3. Read every existing concept/entity page whose name appears in the source — never overwrite a page you haven't read.
4. Pick the source template (Generic / Diary / Meeting / **Method-Software**) and write `knowledge/wiki/sources/<slug>.md`.
5. Update `knowledge/wiki/index.md` — add the new entry under Sources.
6. Update `knowledge/wiki/overview.md` — revise synthesis if warranted.
7. Create or merge entity pages (`knowledge/wiki/entities/`) for key people, companies, projects.
8. Create or merge concept pages (`knowledge/wiki/concepts/`) for key ideas and frameworks.
9. For sources tagged `[method]` or `[software]`: write or update `knowledge/wiki/examples/<slug>.R` (or `.py`) with a verified minimal call, or stub it with `# UNVERIFIED`.
10. Flag any contradictions with existing wiki content — each must cite a verbatim quote from both sides.
11. Append to `knowledge/wiki/log.md`: `## [YYYY-MM-DD] ingest | <Title>`.

After all writes, summarize: what was added, which pages were created or updated, and any contradictions found.
