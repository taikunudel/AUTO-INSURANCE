# /wiki-query

**What it does:** Answers a question against the wiki and synthesizes a response with `[[PageName]]` citations to the pages it drew from.

**When to use it:** Any time you want a wiki-grounded answer — what does the wiki say about X, what are the trade-offs between Y and Z, what are the common pitfalls of method W.

**Usage:** `/wiki-query <question>` — e.g. `/wiki-query what are the failure modes of HDtweedie?`

---

Follow the Query Workflow defined in [CLAUDE.md](../../CLAUDE.md):

1. Read `knowledge/wiki/index.md` to identify the most relevant pages.
2. Grep the question for any token matching a filename under `knowledge/wiki/concepts/`, `knowledge/wiki/entities/`, or `knowledge/wiki/examples/` — read every match. (Index summaries are lossy by design.)
3. Read those pages with the Read tool (up to ~10 most relevant).
4. Synthesize a thorough markdown answer with `[[PageName]]` wikilink citations inline.
5. Include a `## Sources` section at the end listing the pages drawn from.
6. Ask the user if they want the answer saved as `knowledge/wiki/syntheses/<slug>.md`.

If the wiki is empty, say so and suggest running `/wiki-ingest` first.
