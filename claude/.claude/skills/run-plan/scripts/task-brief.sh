#!/usr/bin/env bash
# Extract one task's full text from a plan into its own file and print the path.
#
# The brief is the single source of requirements handed to an implementer.
# Never make a subagent read the whole plan: it burns its context on tasks that
# are not its own, and it starts second-guessing neighbouring work.
#
# Matches a task heading at any depth (`## Task 3:` and `### Task 3:` both work)
# and ends at the next heading of the same or shallower depth, so a task's own
# sub-headings stay with it. Fence-aware: a '#' inside a fenced block is a shell
# comment, not a heading.
#
# Usage: task-brief.sh PLAN_FILE N
set -euo pipefail

[ $# -eq 2 ] || { echo "usage: task-brief.sh PLAN_FILE N" >&2; exit 2; }

plan=$1
n=$2
[ -f "$plan" ] || { echo "no such plan file: $plan" >&2; exit 2; }
case "$n" in
  ''|*[!0-9]*) echo "task number must be a positive integer: $n" >&2; exit 2 ;;
esac

ws=$("$(dirname "$0")/workspace.sh" "$plan")
out="$ws/task-$n-brief.md"

awk -v n="$n" '
  /^```/ { fence = !fence }
  !infile {
    if (!fence && $0 ~ "^##+ Task " n "([:.)]| |$)") {
      match($0, /^#+/); level = RLENGTH
      infile = 1
      print
    }
    next
  }
  fence { print; next }
  /^#/ {
    match($0, /^#+/)
    if (RLENGTH <= level) exit
  }
  { print }
' "$plan" > "$out"

[ -s "$out" ] || {
  echo "no 'Task $n' heading found in $plan" >&2
  rm -f "$out"
  exit 1
}

echo "$out"
