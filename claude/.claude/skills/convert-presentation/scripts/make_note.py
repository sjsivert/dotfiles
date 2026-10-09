#!/usr/bin/env python3
"""Create a vault note for a presentation from its extracted text.

  make_note.py VAULT_TALKS_DIR NAME SOURCE [SOURCE ...] --text FILE.md [--pages N]

Writes VAULT_TALKS_DIR/NAME/NAME.md with front matter (title, sources, date,
pages, status) and the extracted slide text. Never overwrites an existing note.
The original files stay where they are; the note records their paths.
"""
import argparse, datetime, os, sys

ap = argparse.ArgumentParser()
ap.add_argument("talks_dir"); ap.add_argument("name"); ap.add_argument("sources", nargs="+")
ap.add_argument("--text", required=True); ap.add_argument("--pages", default="")
a = ap.parse_args()

folder = os.path.join(os.path.expanduser(a.talks_dir), a.name)
note = os.path.join(folder, a.name + ".md")
if os.path.exists(note):
    sys.exit(f"exists, not overwriting: {note}")
os.makedirs(folder, exist_ok=True)
mtime = max(os.path.getmtime(s) for s in a.sources)
date = datetime.date.fromtimestamp(mtime).isoformat()
text = open(a.text, encoding="utf-8").read().strip()
src = "\n".join(f"  - \"{s}\"" for s in a.sources)
open(note, "w", encoding="utf-8").write(f"""---
title: "{a.name}"
type: presentation
file-date: {date}
pages: {a.pages}
status: text-only
sources:
{src}
tags:
  - talk
---

# {a.name}

## Summary

_Not summarised yet. Run /convert-presentation to add a summary and slide descriptions._

## Slides (extracted text)

{text}
""")
print(note)
