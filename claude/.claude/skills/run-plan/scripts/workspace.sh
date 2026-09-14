#!/usr/bin/env bash
# Resolve (and create) the git-ignored workspace one plan uses for its
# run-plan run: task briefs, implementer reports, review packages, ledger.
#
# One directory per plan (.run-plan/<plan-slug>/) so a second plan in the
# same working tree can never read or overwrite another plan's ledger. A stale
# ledger misread as current progress makes a controller re-dispatch tasks that
# already shipped.
#
# Lives in the working tree (not .git/) because agent writes under .git/ are
# denied. A self-ignoring .gitignore keeps it out of `git status`.
#
# Usage: workspace.sh PLAN_FILE
set -euo pipefail

[ $# -eq 1 ] || { echo "usage: workspace.sh PLAN_FILE" >&2; exit 2; }

plan=$1
[ -f "$plan" ] || { echo "no such plan file: $plan" >&2; exit 2; }

slug=$(basename "$plan" .md)
case "$slug" in
  ""|"."|"..") echo "cannot derive a workspace name from: $plan" >&2; exit 2 ;;
esac

root=$(git rev-parse --show-toplevel)
base="$root/.run-plan"
dir="$base/$slug"
mkdir -p "$dir"
printf '*\n' > "$base/.gitignore"
cd "$dir" && pwd
