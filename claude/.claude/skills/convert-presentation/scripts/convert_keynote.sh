#!/usr/bin/env bash
# Export a Keynote file (.key) to PDF using Keynote itself. Usage: convert_keynote.sh IN.key OUT.pdf
set -euo pipefail
in="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"; out="$2"
osascript - "$in" "$out" <<'OSA'
on run argv
  set inFile to POSIX file (item 1 of argv)
  set outFile to POSIX file (item 2 of argv)
  tell application "Keynote"
    set d to open inFile
    export d to outFile as PDF
    close d saving no
  end tell
end run
OSA
