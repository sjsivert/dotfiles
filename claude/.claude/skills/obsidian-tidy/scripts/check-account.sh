#!/usr/bin/env bash
# Abort unless the active Claude Code login has the required plan.
# Default plan: enterprise. Override with OBSIDIAN_TIDY_PLAN.
want="${OBSIDIAN_TIDY_PLAN:-enterprise}"
if ! out=$(claude auth status 2>/dev/null); then
  echo "ABORT: could not read 'claude auth status'." >&2
  exit 1
fi
plan=$(printf '%s' "$out" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("subscriptionType",""))')
org=$(printf '%s' "$out" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("orgName",""))')
if [ "$plan" != "$want" ]; then
  echo "ABORT: this session is on plan '$plan' (org: $org), need '$want'." >&2
  echo "Start the session with 'claude-ent' (log in once with /login) and run again." >&2
  exit 1
fi
echo "OK: plan '$plan', org '$org'."
