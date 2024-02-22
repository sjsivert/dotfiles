#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch from yabai to swish
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Sindre

echo Stop yabai and start Swish application
brew services stop koekeishiya/formulae/yabai && open -a swish


