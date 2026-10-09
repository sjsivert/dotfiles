---
name: obsidian-tidy
description: Periodic cleanup of an Obsidian vault. Gives generic attachment names (CleanShot, Pasted image) descriptive names by reading the images, and suggests other tidy-ups. Use when the user says "tidy obsidian", "rename screenshots", "clean up my vault" or runs /obsidian-tidy. Only runs on the enterprise Claude plan.
---

# obsidian-tidy

Run from inside the vault (the directory containing `.obsidian/`), or pass its path.

## 0. Gate: enterprise plan only

Run this first, before reading any vault content:

```
~/.claude/skills/obsidian-tidy/scripts/check-account.sh
```

If it exits non-zero, stop. Print its message and tell the user to start a session with `claude-ent`. Do not continue, do not offer a workaround, do not read any images.

## 1. Scan (read-only)

- Find attachments with generic names: `CleanShot *`, `Pasted image *`, `Screenshot *`, `IMG_*`.
- For each, find the note that embeds it and take about 10 lines around the embed as context.
- Also note: attachments no note references, empty notes, notes in the vault root outside the existing folder layout, and duplicates. Report these as suggestions only.

## 2. Name (cheap model)

For each generic attachment, run the `attachment-namer` agent (haiku) with the image's absolute path and its note context. Run them in parallel, in batches of at most 8.

The agent only returns a proposed file name. If it says `unclear`, keep the original name and flag it.

## 3. Propose

Show one table: old name, proposed name, note it appears in. Add the other suggestions below it. Then ask which to apply. Do not change anything yet.

## 4. Apply (only what the user approved)

For each approved rename:

```
python3 -I ~/.claude/skills/obsidian-tidy/scripts/rename_attachment.py VAULT REL_PATH NEW_NAME
```

Set `TIDY_RUN=<one id>` for the whole batch so it can be undone together. The script renames the file and rewrites every `![[...]]`, `[[...]]` and markdown link in the notes, refuses name collisions anywhere in the vault, and logs to `.obsidian/tidy-log.jsonl`.

Never use `mv` on attachments: Obsidian only fixes links for renames made inside the app.

Report the run id and how to undo: `rename_attachment.py VAULT --undo RUN_ID`.

## Notes

- Screenshots are sent to the Anthropic API for naming. Skip folders the user excludes.
- Do not delete anything. Deletions of orphans or empty notes are suggestions the user does themselves, or asks for explicitly.
