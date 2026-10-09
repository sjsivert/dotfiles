---
name: meeting-done
description: Finish a meeting. Finds the Apple Note you wrote for it on the iPad or Mac, links it to the Obsidian meeting note (creating that note from the Outlook calendar if it does not exist yet), and files the Apple Note in the Møter folder. Use for /meeting-done or "meeting done".
---

# meeting-done

Metadata only. Never read or edit the body of an Apple Note: handwriting lives there and a body edit can destroy it. Never delete anything.

## Steps

1. Run `python3 ~/.claude/skills/meeting-done/scripts/meeting_done.py status`. It prints:
   - `meetings_today`: Obsidian meeting notes dated today, with `apple_note` set if already linked,
   - `events_without_note`: today's Outlook events that have no meeting note yet,
   - `candidates`: Apple Notes created in the last 24 hours that no meeting note links to, newest created first (name, folder, `created_local`, `id`).
2. Never ask the user anything: this often runs from Raycast where nobody can answer. Always take `candidates[0]`, the Apple Note created most recently, whatever its name. If there are no candidates, say there is no Apple Note to link and stop.
3. Choose the meeting for it, in this order. A meeting fits when the note's `created_local` falls between 15 minutes before its start and 60 minutes after its end:
   - an entry in `meetings_today` with no `apple_note` that fits: use it,
   - else an entry in `events_without_note` that fits: it has no Obsidian note yet, so create one,
   - else (nothing fits, or the calendar failed, see `calendar_error`): create a note with the Apple Note's name as title.
4. If two meetings fit, take the one that started closest to the note's `created_local`.
5. Run exactly one of these, using the note's `id` verbatim:
   - existing note: `python3 ~/.claude/skills/meeting-done/scripts/meeting_done.py link '<id>' '<md path from meetings_today>'`
   - from a calendar event: `python3 ~/.claude/skills/meeting-done/scripts/meeting_done.py create '<id>' --uid '<uid from events_without_note>'`
   - from the note's name: `python3 ~/.claude/skills/meeting-done/scripts/meeting_done.py create '<id>' --title '<name>'`
   It writes `apple-note:` into the meeting note, adds an "iPad-notat" link under the time line, and moves the Apple Note to `Møter`. Keep the printed meeting-note path.
6. Reply in one or two lines: meeting title, Apple Note name, and whether the meeting note was new. The Outlook event is recorded in the note's `outlook-uid`.
