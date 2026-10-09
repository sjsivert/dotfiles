#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Meeting done
# @raycast.mode silent
# @raycast.icon ✅
# @raycast.packageName Meetings
# Runs /meeting-done on the enterprise Claude account only (same as the claude-ent alias).
export CLAUDE_CONFIG_DIR="$HOME/.claude-enterprise"
export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
unset ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN   # never fall back to a key or another login
cd "$HOME/obsidian" || exit 1

if ! "$HOME/.claude/skills/convert-presentation/scripts/check-account.sh" >/dev/null 2>&1; then
  echo "Not logged in to the enterprise plan. Run 'claude-ent' and /login once." >&2
  exit 1
fi
claude -p "/meeting-done" --allowedTools "Bash(python3:*)" </dev/null 2>&1 | tail -n 3
