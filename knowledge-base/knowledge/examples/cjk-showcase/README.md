# CJK Showcase (Chinese Language Example)

This directory demonstrates how LLM Wiki Agent performs with Non-English (CJK) languages.

The agent naturally supports processing Chinese content. With the CJK query bug fixed, you can ingest, query, and linguistically search across Chinese entries without any language-specific configuration. 

## Files included in this showcase:

- `knowledge/raw/2026-04-13-reflection.md`: A sample source document (a personal reflection on career transition).
- `knowledge/wiki/sources/2026-04-13-reflection.md`: The parsed structured source page.
- `knowledge/wiki/entities/杨帆.md`: Auto-extracted Chinese entity page.
- `knowledge/wiki/concepts/AI转型.md`: Auto-extracted Chinese concept page.

Try running `python tools/query.py "关于AI转型的建议"` from the root directory after moving these to your main knowledge base to see how semantic extraction and keyword matching behave in non-English contexts!
