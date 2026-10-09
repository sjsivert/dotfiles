---
name: convert-presentation
description: Turn Keynote/PowerPoint/PDF presentations into searchable Markdown notes in the Obsidian vault, with a summary and a one-line description per slide. Use for "convert presentation", "add presentations to obsidian", or when Talks/ notes have status text-only. Only runs on the enterprise Claude plan.
---

# convert-presentation

Notes live in `<vault>/Talks/<name>/<name>.md`. Originals stay where they are; the note's `sources:` front matter records their paths. No PDFs are copied into the vault (they are large and slow Obsidian Sync).

## 0. Gate: enterprise plan only

Run first, before reading any presentation content or page images:

```
~/.claude/skills/convert-presentation/scripts/check-account.sh
```

If it exits non-zero, stop, print its message and tell the user to start with `claude-ent`. No workaround.

## 1. Find work

- New decks: the user names a folder or files. For each, create the note skeleton (steps 2 and 3).
- Existing notes: `grep -l "status: text-only" Talks/*/*.md`. These only need step 4.

## 2. Get text (local, no API)

- `.pptx` / `.pdf`: `python3 -I scripts/extract_text.py FILE > text.md`
- `.key`: `scripts/convert_keynote.sh IN.key OUT.pdf` (Keynote exports it), then `extract_text.py OUT.pdf`. Cache PDFs in `~/.cache/convert-presentation/pdf/<name>.pdf`.

## 3. Create the note skeleton (local)

```
python3 -I scripts/make_note.py VAULT/Talks NAME SOURCE... --text text.md --pages N
```

It refuses to overwrite an existing note.

## 4. Describe (cheap model)

For each text-only note:
1. Take the cached PDF for it (export again from `sources:` if missing). Render pages: `pdftoppm -r 60 -png PDF /tmp/<name>/p`.
2. Run one agent per deck on `model: haiku` (general-purpose agent), at most 6 at a time, in parallel. Give it the page image paths and the extracted text. It must read every page image and return:
   - a 3 to 5 line summary (what the talk is about, audience, main takeaways),
   - one line per slide describing what it shows, including diagrams and screenshots that text extraction misses,
   - 3 to 6 tags (lowercase, no spaces).
3. Edit the note: replace the `_Not summarised yet_` line with the summary, add a `## Slide descriptions` section above the extracted text, merge the tags into the front matter, set `status: described`.

## 5. Index

Update `Talks/index.md`: one row per deck with link, date and one-line summary.

## Notes

- Page images and text go to the Anthropic API. Skip decks the user excludes.
- Never delete originals. Do not copy large PDFs into the vault unless the user asks for a compressed copy.
