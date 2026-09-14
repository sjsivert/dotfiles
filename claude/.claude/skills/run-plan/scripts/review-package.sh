#!/usr/bin/env bash
# Write the commit list, stat summary and full diff for BASE..HEAD to one file
# and print its path. Reviewers get the path, never the diff itself — the
# output must not enter the controller's context, where it would be re-read on
# every later turn for the rest of the session.
#
# BASE is the commit recorded before dispatching the implementer. Never HEAD~1:
# it silently drops all but the last commit of a multi-commit task.
#
# Usage: review-package.sh PLAN_FILE BASE HEAD
set -euo pipefail

[ $# -eq 3 ] || { echo "usage: review-package.sh PLAN_FILE BASE HEAD" >&2; exit 2; }

plan=$1
base=$2
head=$3
[ -f "$plan" ] || { echo "no such plan file: $plan" >&2; exit 2; }

for ref in "$base" "$head"; do
  git rev-parse --verify --quiet "$ref^{commit}" >/dev/null \
    || { echo "not a commit: $ref" >&2; exit 2; }
done

ws=$("$(dirname "$0")/workspace.sh" "$plan")
short_base=$(git rev-parse --short "$base")
short_head=$(git rev-parse --short "$head")
out="$ws/review-$short_base..$short_head.md"

{
  echo "# Review package: $short_base..$short_head"
  echo
  echo '## Commits'
  echo '```'
  git log --oneline "$base..$head"
  echo '```'
  echo
  echo '## Files changed'
  echo '```'
  git diff --stat "$base..$head"
  echo '```'
  echo
  echo '## Diff'
  echo '```diff'
  git diff -U10 "$base..$head"
  echo '```'
} > "$out"

# A reviewer Reads this file in one call. Past a few hundred KB that gets paged
# or truncated, and a reviewer silently judging half a diff is worse than no
# review — split the task or review the package in named slices.
bytes=$(wc -c < "$out" | tr -d ' ')
if [ "$bytes" -gt 400000 ]; then
  echo "warning: review package is $((bytes / 1024)) KB — too large for one Read." >&2
  echo "         Dispatch reviewers per file group, or split the task." >&2
fi

echo "$out"
