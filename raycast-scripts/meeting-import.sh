#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Meeting done + import Apple Note
# @raycast.mode silent
# @raycast.icon 📥
# @raycast.packageName Meetings
# Links the Apple Note like "Meeting done", then copies its text and transcribes handwriting/images
# into the Obsidian meeting note. Enterprise account only. Takes 30-90 s.
export CLAUDE_CONFIG_DIR="$HOME/.claude-enterprise"
export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
unset ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN
cd "$HOME/obsidian" || exit 1

if ! "$HOME/.claude/skills/convert-presentation/scripts/check-account.sh" >/dev/null 2>&1; then
  echo "Not logged in to the enterprise plan. Run 'claude-ent' and /login once." >&2
  exit 1
fi
claude -p "/meeting-import" \
  --allowedTools "Bash(python3:*)" "Read" "Edit(~/obsidian/Meeting notes/**)" </dev/null 2>&1 | tail -n 4
