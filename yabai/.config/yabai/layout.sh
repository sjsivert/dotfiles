#!/bin/sh
# Put spaces and windows back where they were after macOS moves them.
# yabairc runs it from signals:
#
#   layout.sh save          as windows and spaces change: remember how many
#                           spaces each display has and where every window is
#   layout.sh suspend       when a display goes away: stop saving
#   layout.sh restore [-n]  when a display comes back or the Mac wakes: give
#                           each display its spaces and each window its space,
#                           then save again. -n prints what it would do.
#
# A monitor that sleeps with the screen can drop off the Mac. macOS then moves
# its spaces and windows to the laptop, and leaves them there when the monitor
# wakes. Saving stops while the monitor is gone, so the saved layout is the
# one from before. The log goes to /tmp/yabai_$USER.out.log.

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

save() {
  [ -e "$suspended" ] && return
  displays=$(yabai -m query --displays) || return
  # One display is the laptop on its own, or a monitor that has gone away.
  [ "$(echo "$displays" | jq length)" -ge 2 ] || return
  mkdir -p "$dir"
  # A window's place is its display and the position of its space there,
  # which still holds if macOS adds a space to another display.
  yabai -m query --windows | jq --argjson d "$displays" '{
    displays: [$d[] | {uuid, spaces: (.spaces | length)}],
    windows: [.[] | select(."is-sticky" | not) | . as $w
      | ($d[] | select(.index == $w.display)) as $display
      | {id, app, display: $display.uuid, pos: ($display.spaces | index($w.space))}
      | select(.pos != null)]
  }' >"$layout.$$" && mv "$layout.$$" "$layout"
}

# "<display index> <spaces now> <spaces saved>" for each display
space_counts() {
  yabai -m query --displays | jq -r --slurpfile l "$layout" '
    ($l[0].displays | map({key: .uuid, value: .spaces}) | from_entries) as $saved
    | .[] | "\(.index) \(.spaces | length) \($saved[.uuid])"'
}

# Give each display back as many spaces as it had: take spare ones from the
# other display, or make new ones.
add_spaces() {
  i=0
  while [ $i -lt 10 ]; do
    i=$((i + 1))
    counts=$(space_counts)
    short=$(echo "$counts" | awk '$2 < $3 { print $1; exit }')
    [ -n "$short" ] || return
    spare=$(echo "$counts" | awk '$2 > $3 { print $1; exit }')
    space=
    [ -n "$spare" ] && space=$(yabai -m query --spaces --display "$spare" |
      jq 'map(select(."is-visible" | not)) | last.index // empty')
    if [ -n "$space" ]; then
      run yabai -m space "$space" --display "$short"
    else
      run yabai -m space --create "$short"
    fi
    # The counts above do not change in a dry run.
    [ -z "$dry" ] || return
  done
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

# Spaces beyond what a display had go, once their windows have moved out.
remove_spaces() {
  space_counts | while read -r display now saved; do
    extra=$((now - saved))
    [ "$extra" -gt 0 ] || continue
    yabai -m query --spaces --display "$display" | jq -r 'reverse | .[]
      | select(."is-visible" | not) | .index' |
      while read -r space; do
        [ "$extra" -gt 0 ] || break
        windows=$(yabai -m query --windows --space "$space" |
          jq 'map(select(."is-sticky" | not)) | length')
        [ "$windows" -eq 0 ] || continue
        run yabai -m space "$space" --destroy
        extra=$((extra - 1))
      done
  done
}

restore() {
  [ "${1:-}" = -n ] && dry=1
  [ -r "$layout" ] || return
  if [ -z "$dry" ]; then
    mkdir -p "$dir" && touch "$suspended"
    # Let macOS finish moving things first.
    sleep 3
  fi
  displays=$(yabai -m query --displays) || return
  # The monitor is not back yet: stay suspended until it is.
  [ "$(echo "$displays" | jq length)" -ge 2 ] || return
  if [ "$(echo "$displays" | jq -c '[.[].uuid] | sort')" != \
    "$(jq -c '[.displays[].uuid] | sort' "$layout")" ]; then
    log "not the saved displays, so starting a new layout"
  else
    add_spaces
    move_windows
    remove_spaces
  fi
  [ -n "$dry" ] && return
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
