#!/bin/sh
# Focus a space or a display. skhd calls this:
#
#   focus.sh space 3
#   focus.sh display west
#
# On its own, yabai gives focus to the frontmost window on the other display.
# Wispr Flow's bar floats above every space on the main monitor and does not
# take focus, so switching to that monitor left no window focused. When that
# happens, this focuses the space's frontmost real window instead.

case $1 in
space) space=$(yabai -m query --spaces --space "$2" | jq .index) ;;
display) space=$(yabai -m query --spaces --display "$2" | jq '.[] | select(."is-visible").index') ;;
*)
  echo "usage: focus.sh space <space> | display <display>" >&2
  exit 2
  ;;
esac

[ -n "$space" ] && yabai -m space --focus "$space" || exit 1

# Let the switch finish first. Focusing a window while macOS is still
# switching can send it back to the old space.
i=0
while [ $i -lt 10 ]; do
  sleep 0.05
  focused=$(yabai -m query --windows --window 2>/dev/null | jq .space)
  [ "$focused" = "$space" ] && exit 0
  [ -z "$focused" ] && break
  i=$((i + 1))
done

# The windows come front to back. Skip floating bars and panels, minimized
# windows and windows shown on every space.
window=$(yabai -m query --windows --space "$space" | jq '
  map(select(.role == "AXWindow" and .layer == "normal"
    and (."is-sticky" or ."is-minimized" or ."is-hidden" | not)))
  | first.id // empty')

[ -n "$window" ] && yabai -m window --focus "$window"
