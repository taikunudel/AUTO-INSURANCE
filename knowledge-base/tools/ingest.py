#!/usr/bin/env python3
"""
Ingest a source document into the LLM Wiki.

Usage:
    python tools/ingest.py <path-to-source>
    python tools/ingest.py knowledge/raw/articles/my-article.md
    python tools/ingest.py report.pdf                  # auto-converts to .md
    python tools/ingest.py slides.pptx notes.docx       # batch, mixed formats
    python tools/ingest.py knowledge/raw/mixed/ --no-convert      # skip auto-conversion
    python tools/ingest.py --validate-only              # run validation only

Supported formats (auto-converted via markitdown):
    .pdf .docx .pptx .xlsx .html .htm .txt .csv .json .xml
    .rst .rtf .epub .ipynb .yaml .yml .tsv .wav .mp3

The LLM reads the source, extracts knowledge, and updates the wiki:
  - Creates knowledge/wiki/sources/<slug>.md
  - Updates knowledge/wiki/index.md
  - Updates knowledge/wiki/overview.md (if warranted)
  - Creates/updates entity and concept pages
  - Appends to knowledge/wiki/log.md
  - Flags contradictions
  - Runs post-ingest validation (broken links, index coverage)
"""

import os
import sys
import json
import hashlib
import re
import shutil
import tempfile
from pathlib import Path
from collections import defaultdict
from datetime import date

REPO_ROOT = Path(__file__).parent.parent
WIKI_DIR = REPO_ROOT / "knowledge" / "wiki"
LOG_FILE = WIKI_DIR / "log.md"
INDEX_FILE = WIKI_DIR / "index.md"
OVERVIEW_FILE = WIKI_DIR / "overview.md"

# File extensions that can be auto-converted to markdown via markitdown.
# .md files are ingested directly without conversion.
CONVERTIBLE_EXTENSIONS = {
    ".pdf", ".docx", ".pptx", ".xlsx", ".xls",
    ".html", ".htm", ".txt", ".csv", ".json", ".xml",
    ".rst", ".rtf", ".epub", ".ipynb",
    ".yaml", ".yml", ".tsv",
    ".wav", ".mp3",  # audio transcription via markitdown
}
ALL_SUPPORTED_EXTENSIONS = {".md"} | CONVERTIBLE_EXTENSIONS
SCHEMA_FILE = REPO_ROOT / "CLAUDE.md"


def sha256(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()[:16]


def read_file(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def call_llm(prompt: str, max_tokens: int = 8192) -> str:
    try:
        from litellm import completion
    except ImportError:
        print("Error: litellm not installed. Run: pip install litellm")
        sys.exit(1)
        
    model = os.getenv("LLM_MODEL", "claude-3-5-sonnet-latest")
    
    kwargs = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}]
    }
    
    if max_tokens:
        kwargs["max_tokens"] = max_tokens

    response = completion(**kwargs)
    return response.choices[0].message.content


def write_file(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    print(f"  wrote: {path.relative_to(REPO_ROOT)}")


def build_wiki_context() -> str:
    parts = []
    if INDEX_FILE.exists():
        parts.append(f"## knowledge/wiki/index.md\n{read_file(INDEX_FILE)}")
    if OVERVIEW_FILE.exists():
        parts.append(f"## knowledge/wiki/overview.md\n{read_file(OVERVIEW_FILE)}")
    # Include a few recent source pages for contradiction checking
    sources_dir = WIKI_DIR / "sources"
    if sources_dir.exists():
        recent = sorted(sources_dir.glob("*.md"), key=lambda p: p.stat().st_mtime, reverse=True)[:5]
        for p in recent:
            parts.append(f"## {p.relative_to(REPO_ROOT)}\n{p.read_text()}")
    return "\n\n---\n\n".join(parts)


def parse_json_from_response(text: str) -> dict:
    # Strip markdown code fences if present
    text = re.sub(r"^```(?:json)?\s*", "", text.strip())
    text = re.sub(r"\s*```$", "", text.strip())
    # Find the outermost JSON object
    match = re.search(r"\{[\s\S]*\}", text)
    if not match:
        raise ValueError("No JSON object found in response")
    return json.loads(match.group())


def update_index(new_entry: str, section: str = "Sources"):
    content = read_file(INDEX_FILE)
    if not content:
        content = "# Wiki Index\n\n## Overview\n- [Overview](overview.md) — living synthesis\n\n## Sources\n\n## Entities\n\n## Concepts\n\n## Syntheses\n"
    section_header = f"## {section}"
    if section_header in content:
        content = content.replace(section_header + "\n", section_header + "\n" + new_entry + "\n")
    else:
        content += f"\n{section_header}\n{new_entry}\n"
    write_file(INDEX_FILE, content)


def append_log(entry: str):
    existing = read_file(LOG_FILE)
    write_file(LOG_FILE, entry.strip() + "\n\n" + existing)


def extract_wikilinks(content: str) -> list[str]:
    """Extract all [[WikiLink]] targets from page content."""
    return re.findall(r'\[\[([^\]]+)\]\]', content)


def all_wiki_pages() -> set[str]:
    """Return set of all wiki page stems (case-insensitive)."""
    pages = set()
    for p in WIKI_DIR.rglob("*.md"):
        if p.name not in ("index.md", "log.md", "lint-report.md"):
            pages.add(p.stem.lower())
    return pages


def validate_ingest(changed_pages: list[str] | None = None) -> dict:
    """Validate wiki integrity after an ingest.

    Checks:
      1. Broken wikilinks in changed pages (or all pages if none specified)
      2. Pages not registered in index.md

    Returns dict with 'broken_links' and 'unindexed' lists.
    """
    existing_pages = all_wiki_pages()
    index_content = read_file(INDEX_FILE).lower()

    # Determine which pages to scan for broken links
    if changed_pages:
        scan_paths = [WIKI_DIR / p for p in changed_pages if (WIKI_DIR / p).exists()]
    else:
        scan_paths = [p for p in WIKI_DIR.rglob("*.md")
                      if p.name not in ("index.md", "log.md", "lint-report.md")]

    # Check 1: Broken wikilinks
    broken_links = []
    for page_path in scan_paths:
        content = read_file(page_path)
        rel = str(page_path.relative_to(WIKI_DIR))
        for link in extract_wikilinks(content):
            # Normalize: strip paths, check stem only
            link_stem = Path(link).stem.lower() if '/' in link else link.lower()
            if link_stem not in existing_pages:
                broken_links.append((rel, link))

    # Check 2: Unindexed pages (only check changed pages)
    unindexed = []
    for p in (changed_pages or []):
        page_path = WIKI_DIR / p
        if page_path.exists():
            # Check if the page filename appears in index.md
            stem = page_path.stem.lower()
            if stem not in index_content and p not in ("log.md", "overview.md"):
                unindexed.append(p)

    return {"broken_links": broken_links, "unindexed": unindexed}


def convert_to_md(source: Path) -> Path:
    """Convert a non-markdown file to .md using markitdown.

    Returns the path to the converted .md file (placed next to the original
    with a .md extension, or in a temp location if the source dir is read-only).
    """
    try:
        from markitdown import MarkItDown
    except ImportError:
        print("Error: markitdown not installed (needed to convert non-.md files).")
        print("  Install with: pip install markitdown")
        sys.exit(1)

    md = MarkItDown(enable_plugins=False)
    try:
        result = md.convert(str(source))
    except Exception as e:
        print(f"Error: failed to convert '{source.name}': {e}")
        sys.exit(1)

    # Write converted output next to source as <name>.md
    output = source.with_suffix(".md")
    try:
        output.write_text(result.text_content, encoding="utf-8")
    except OSError:
        # Fallback: source directory may be read-only
        tmp = Path(tempfile.mkdtemp()) / f"{source.stem}.md"
        tmp.write_text(result.text_content, encoding="utf-8")
        output = tmp

    print(f"  ✓ Converted {source.name} → {output.name}")
    return output


def ingest(source_path: str, auto_convert: bool = True):
    source = Path(source_path)
    if not source.exists():
        print(f"Error: file not found: {source_path}")
        sys.exit(1)

    # Auto-convert non-markdown files
    converted_path = None
    if source.suffix.lower() != ".md":
        if not auto_convert:
            print(f"  Skipping non-.md file (--no-convert): {source.name}")
            return
        if source.suffix.lower() not in CONVERTIBLE_EXTENSIONS:
            print(f"  ⚠️  Unsupported format: {source.suffix} — skipping {source.name}")
            print(f"       Supported: {', '.join(sorted(ALL_SUPPORTED_EXTENSIONS))}")
            return
        print(f"  Converting {source.name} to markdown...")
        converted_path = convert_to_md(source)
        source = converted_path

    source_content = source.read_text(encoding="utf-8")
    source_hash = sha256(source_content)
    today = date.today().isoformat()

    print(f"\nIngesting: {source.name}  (hash: {source_hash})")

    wiki_context = build_wiki_context()
    schema = read_file(SCHEMA_FILE)

    prompt = f"""You are maintaining an LLM Wiki. Process this source document and integrate its knowledge into the wiki.

Schema and conventions:
{schema}

Current wiki state (index + recent pages):
{wiki_context if wiki_context else "(wiki is empty — this is the first source)"}

New source to ingest (file: {source.relative_to(REPO_ROOT) if source.is_relative_to(REPO_ROOT) else source.name}):
=== SOURCE START ===
{source_content}
=== SOURCE END ===

Today's date: {today}

Return ONLY a valid JSON object with these fields (no markdown fences, no prose outside the JSON):
{{
  "title": "Human-readable title for this source",
  "slug": "kebab-case-slug-for-filename",
  "source_page": "full markdown content for knowledge/wiki/sources/<slug>.md — use the source page format from the schema. CRITICAL: Aggressively convert key people, products, concepts and projects into [[Wikilinks]] inline in the text. Omitting [[ ]] for known terms is a failure.",
  "index_entry": "- [Title](sources/slug.md) — one-line summary",
  "overview_update": "full updated content for knowledge/wiki/overview.md, or null if no update needed",
  "entity_pages": [
    {{"path": "entities/EntityName.md", "content": "full markdown content"}}
  ],
  "concept_pages": [
    {{"path": "concepts/ConceptName.md", "content": "full markdown content"}}
  ],
  "contradictions": ["describe any contradiction with existing wiki content, or empty list"],
  "log_entry": "## [{today}] ingest | <title>\\n\\nAdded source. Key claims: ..."
}}
"""

    print(f"  calling API (model: ...)")
    raw = call_llm(prompt, max_tokens=8192)
    try:
        data = parse_json_from_response(raw)
    except (ValueError, json.JSONDecodeError) as e:
        print(f"Error parsing API response: {e}")
        print("Raw response saved to /tmp/ingest_debug.txt")
        Path("/tmp/ingest_debug.txt").write_text(raw)
        sys.exit(1)

    # Write source page
    slug = data["slug"]
    write_file(WIKI_DIR / "sources" / f"{slug}.md", data["source_page"])

    # Write entity pages
    for page in data.get("entity_pages", []):
        write_file(WIKI_DIR / page["path"], page["content"])

    # Write concept pages
    for page in data.get("concept_pages", []):
        write_file(WIKI_DIR / page["path"], page["content"])

    # Update overview
    if data.get("overview_update"):
        write_file(OVERVIEW_FILE, data["overview_update"])

    # Update index
    update_index(data["index_entry"], section="Sources")

    # Append log
    append_log(data["log_entry"])

    # Report contradictions
    contradictions = data.get("contradictions", [])
    if contradictions:
        print("\n  ⚠️  Contradictions detected:")
        for c in contradictions:
            print(f"     - {c}")

    # --- Post-ingest validation ---
    created_pages = [f"sources/{slug}.md"]
    for page in data.get("entity_pages", []):
        created_pages.append(page["path"])
    for page in data.get("concept_pages", []):
        created_pages.append(page["path"])
    updated_pages = ["index.md", "log.md"]
    if data.get("overview_update"):
        updated_pages.append("overview.md")

    validation = validate_ingest(created_pages)

    print(f"\n{'='*50}")
    print(f"  ✅ Ingested: {data['title']}")
    print(f"{'='*50}")
    print(f"  Created : {len(created_pages)} pages")
    for p in created_pages:
        print(f"           + knowledge/wiki/{p}")
    print(f"  Updated : {len(updated_pages)} pages")
    for p in updated_pages:
        print(f"           ~ knowledge/wiki/{p}")
    if contradictions:
        print(f"  Warnings: {len(contradictions)} contradiction(s)")
    if validation["broken_links"]:
        print(f"  ⚠️  Broken links: {len(validation['broken_links'])}")
        for page, link in validation["broken_links"][:10]:
            print(f"           knowledge/wiki/{page} → [[{link}]]")
        if len(validation["broken_links"]) > 10:
            print(f"           ... and {len(validation['broken_links']) - 10} more")
    if validation["unindexed"]:
        print(f"  ⚠️  Not in index.md: {len(validation['unindexed'])}")
        for p in validation["unindexed"][:10]:
            print(f"           knowledge/wiki/{p}")
        if len(validation["unindexed"]) > 10:
            print(f"           ... and {len(validation['unindexed']) - 10} more")
    if not validation["broken_links"] and not validation["unindexed"]:
        print("  ✓ Validation passed — no broken links, all pages indexed")
    print()


if __name__ == "__main__":
    # Handle --validate-only flag
    if len(sys.argv) == 2 and sys.argv[1] == "--validate-only":
        print("Running wiki validation (no ingest)...\n")
        result = validate_ingest()
        if result["broken_links"]:
            print(f"Broken wikilinks: {len(result['broken_links'])}")
            for page, link in result["broken_links"][:20]:
                print(f"  knowledge/wiki/{page} → [[{link}]]")
            if len(result["broken_links"]) > 20:
                print(f"  ... and {len(result['broken_links']) - 20} more")
        else:
            print("No broken wikilinks found.")
        print()
        pages = all_wiki_pages()
        index_content = read_file(INDEX_FILE).lower()
        unindexed_all = []
        for p in WIKI_DIR.rglob("*.md"):
            if p.name in ("index.md", "log.md", "lint-report.md", "overview.md"):
                continue
            if p.stem.lower() not in index_content:
                unindexed_all.append(str(p.relative_to(WIKI_DIR)))
        if unindexed_all:
            print(f"Pages not in index.md: {len(unindexed_all)}")
            for up in unindexed_all[:20]:
                print(f"  knowledge/wiki/{up}")
            if len(unindexed_all) > 20:
                print(f"  ... and {len(unindexed_all) - 20} more")
        else:
            print("All pages are indexed.")
        sys.exit(0)

    # Parse flags
    no_convert = "--no-convert" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]

    if not args:
        print("Usage: python tools/ingest.py <path-to-source> [path2 ...] [dir1 ...]")
        print("       python tools/ingest.py --validate-only")
        print("       python tools/ingest.py --no-convert  # skip auto-conversion of non-.md files")
        print(f"\nSupported formats: {', '.join(sorted(ALL_SUPPORTED_EXTENSIONS))}")
        sys.exit(1)

    paths_to_process = []
    for arg in args:
        p = Path(arg)
        if p.is_file():
            ext = p.suffix.lower()
            if ext in ALL_SUPPORTED_EXTENSIONS:
                paths_to_process.append(p)
            else:
                print(f"  ⚠️  Skipping unsupported format: {p.name} ({ext})")
        elif p.is_dir():
            for f in p.rglob("*"):
                if f.is_file() and f.suffix.lower() in ALL_SUPPORTED_EXTENSIONS:
                    paths_to_process.append(f)
        else:
            import glob
            for f in glob.glob(arg, recursive=True):
                g_p = Path(f)
                if g_p.is_file() and g_p.suffix.lower() in ALL_SUPPORTED_EXTENSIONS:
                    paths_to_process.append(g_p)

    # Deduplicate while preserving order
    unique_paths = []
    seen = set()
    for p in paths_to_process:
        abs_p = p.resolve()
        if abs_p not in seen:
            seen.add(abs_p)
            unique_paths.append(p)

    if not unique_paths:
        print("Error: no supported files found to ingest.")
        print(f"Supported formats: {', '.join(sorted(ALL_SUPPORTED_EXTENSIONS))}")
        sys.exit(1)

    if len(unique_paths) > 1:
        print(f"Batch mode: found {len(unique_paths)} files to ingest.")

    for p in unique_paths:
        ingest(str(p), auto_convert=not no_convert)
