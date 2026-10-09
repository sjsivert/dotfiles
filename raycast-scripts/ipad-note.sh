#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title iPad note for meeting
# @raycast.mode compact
# @raycast.icon ✍️
# @raycast.packageName Meetings
# Creates an Apple Note for the latest meeting note and links the two.
exec python3 "$(dirname "$0")/ipad_note.py" "$@"
