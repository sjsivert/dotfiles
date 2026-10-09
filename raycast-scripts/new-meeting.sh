#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title New meeting note
# @raycast.mode compact
# @raycast.icon 📝
# @raycast.packageName Meetings
# @raycast.argument1 { "type": "text", "placeholder": "Title (empty = current Outlook meeting)", "optional": true }
# Needs ~/.config/meeting-note/{config,venv} (kept out of the repo).
exec "$HOME/.config/meeting-note/venv/bin/python" "$(dirname "$0")/new_meeting.py" "$@"
