---
name: meeting-import
description: Finish a meeting and pull the Apple Note's content into Obsidian. Does what /meeting-done does (including creating the meeting note from the calendar when there is none), then copies the note's typed text and transcribes handwriting and images into the meeting note. Use for /meeting-import or "meeting done and extract".
---

# meeting-import

Step 1 is `/meeting-done` (linking and filing). Step 2 reads the note's content. Reading the content is allowed here because the user asked for it; still never edit or delete anything in Apple Notes, only in the Obsidian meeting note. Everything you read goes to the API, so do not copy anything anywhere else.

## Steps

1. Do everything in `~/.claude/skills/meeting-done/SKILL.md`. Note the meeting note's path (`Meeting notes/....md`). If it is already linked, use `meetings_today` to find the path and carry on. If meeting-done stops because there is no Apple Note, stop here too. Never ask the user anything; meeting-done picks the newest created Apple Note.
2. Run `python3 ~/.claude/skills/meeting-import/scripts/extract_note.py '<meeting note path>'`. It prints JSON with `typed_text` and `images`, and has already copied shrunken images into `Meeting notes/Attachment/`. If it says `already_imported`, report that and stop.
3. Read each image with the Read tool (path = `~/obsidian/` + `vault_path`):
   - Handwriting: transcribe it faithfully, keep its structure (headings, bullets, checkboxes, arrows), mark unclear words with `[?]`. The `apple_handwriting_hint` is a rough machine guess; trust the image over it.
   - Photo or diagram: one line saying what it shows, plus any text you can read in it.
4. Edit the meeting note (Edit tool, only that file). Insert a new section right before `## Beslutninger`:

   ```
   ## Fra Apple Notes
   <!-- apple-note-import -->
   <typed_text, as is>

   ### Håndskrift og bilder
   <for each image: its embed line, then the transcription or description>
   ```
   Leave the user's own text under `## Notater` untouched. Skip empty parts (no `typed_text` or no images).
5. Do not add action items or decisions to the other sections on your own. If the text clearly contains tasks, list them under the new section as a short "Mulige oppfølginger" list for the user to move.
6. Reply in two lines: what was imported (characters of text, number of images) and where.
