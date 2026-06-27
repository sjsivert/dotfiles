#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Context window: percentage + used/total tokens in k (rounded)
CONTEXT=$(echo "$input" | jq -r '" | 🧠 \(.context_window.used_percentage // 0)% · \((.context_window.total_input_tokens // 0)/1000*10|round/10)k/\((.context_window.context_window_size // 0)/1000|floor)k"')

# Show git branch if in a git repo
GIT_BRANCH=""
cd "$CURRENT_DIR" 2>/dev/null
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | 🌿 $BRANCH"
    fi
fi

echo "[$MODEL_DISPLAY] 📁 ${CURRENT_DIR##*/}$GIT_BRANCH$CONTEXT"
