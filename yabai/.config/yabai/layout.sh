#!/bin/sh
# Put windows back on their spaces after macOS moves them. yabairc runs it
# from signals:
#
#   layout.sh save          as windows and spaces change: remember how many
#                           spaces each display has and where every window is
#   layout.sh suspend       when a display goes away: stop saving
#   layout.sh restore [-n]  when a display comes back or the Mac wakes: wait
#                           for macOS to put the spaces back, then move each
#                           window to its space and save again. -n prints the
#                           moves it would make now.
#
# When the screen wakes, the monitor drops off the Mac for a moment. macOS
# moves its spaces and windows to the laptop and then back, but not every
# window lands on its old space. Saving stops while the monitor is gone, so
# the saved layout is the one from before.
#
# It never moves spaces itself. macOS does that, and display numbers change
# while it does: moving spaces then sent them to the wrong display. If the
# spaces do not come back as they were, the windows stay where they are.
# The log goes to /tmp/yabai_$USER.out.log.

dir=${XDG_STATE_HOME:-$HOME/.local/state}/yabai
layout=$dir/layout.json
suspended=$dir/suspended
dry=

log() { echo "$(date '+%F %T') layout.sh: $*"; }

# Log the command, and run it unless this is a dry run.
run() {
  log "$*"
  [ -n "$dry" ] || "$@"
}

# The displays in order, with how many spaces each has.
shape() {
  yabai -m query --displays | jq -c '[.[] | {uuid, spaces: (.spaces | length)}]'
}

save() {
  [ -e "$suspended" ] && return
  displays=$(yabai -m query --displays) || return
  # One display is the laptop on its own, or a monitor that has gone away.
  [ "$(echo "$displays" | jq length)" -ge 2 ] || return
  mkdir -p "$dir"
  # A window's place is its display and the position of its space there.
  yabai -m query --windows | jq --argjson d "$displays" '{
    displays: [$d[] | {uuid, spaces: (.spaces | length)}],
    windows: [.[] | select(."is-sticky" | not) | . as $w
      | ($d[] | select(.index == $w.display)) as $display
      | {id, app, display: $display.uuid, pos: ($display.spaces | index($w.space))}
      | select(.pos != null)]
  }' >"$layout.$$" && mv "$layout.$$" "$layout"
}

# Wait up to 30 seconds for the displays and spaces to be as saved, and
# still so a second later.
settled() {
  saved=$(jq -c .displays "$layout")
  i=0
  while [ $i -lt 30 ]; do
    i=$((i + 1))
    sleep 1
    [ "$(shape)" = "$saved" ] || continue
    sleep 1
    [ "$(shape)" = "$saved" ] && return 0
  done
  return 1
}

move_windows() {
  yabai -m query --windows | jq -r --slurpfile l "$layout" \
    --argjson d "$(yabai -m query --displays)" '
    ($d | map({key: .uuid, value: .spaces}) | from_entries) as $spaces
    | (map({key: (.id | tostring), value: .space}) | from_entries) as $now
    | $l[0].windows[]
    | $spaces[.display][.pos] as $want
    | $now[.id | tostring] as $space
    | select($want != null and $space != null and $space != $want)
    | "\(.id) \($want) \(.app)"' |
    while read -r id space app; do
      log "$app back to space $space"
      run yabai -m window "$id" --space "$space"
    done
}

restore() {
  [ "${1:-}" = -n ] && dry=1
  [ -r "$layout" ] || return
  if [ -n "$dry" ]; then
    [ "$(shape)" = "$(jq -c .displays "$layout")" ] ||
      log "the spaces are not as saved, so it would wait for them"
    move_windows
    return
  fi

  # display_added and system_woke can both fire. One restore is enough.
  mkdir -p "$dir"
  mkdir "$dir/restoring" 2>/dev/null || return
  trap 'rmdir "$dir/restoring"' EXIT
  touch "$suspended"

  log "a display is back, so waiting for macOS to put the spaces back"
  if settled; then
    move_windows
  elif [ "$(yabai -m query --displays | jq length)" -lt 2 ]; then
    # The monitor is still gone. Stay suspended until it is back.
    return
  else
    log "the spaces did not come back as saved, so the windows stay put"
  fi
  rm -f "$suspended"
  save
}

case ${1:-} in
  save) save ;;
  suspend)
    log "a display went away, so saving stops until it is back"
    mkdir -p "$dir" && touch "$suspended"
    ;;
  restore) shift && restore "$@" ;;
  *)
    echo "usage: layout.sh save | suspend | restore [-n]" >&2
    exit 2
    ;;
esac
