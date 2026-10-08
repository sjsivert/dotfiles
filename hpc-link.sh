#!/usr/bin/env bash
# Minimal stand-in for GNU stow, for machines without stow, Nix or root
# (e.g. the Olivia login node). Symlinks every file in the chosen packages
# into $HOME, one link per file, like `stow --no-folding`.
#
#   ./hpc-link.sh [-n] [-D] [package ...]
#
#   -n  dry run, only print what would happen
#   -D  remove the links instead of creating them
#
# With no packages it uses the default list below. Existing real files are
# moved to <file>.bak, never overwritten.

set -euo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TARGET=${TARGET:-$HOME}
DEFAULT_PACKAGES=(zsh git tmux vim nvim)

dry=0
unlink=0
while getopts "nD" opt; do
  case $opt in
    n) dry=1 ;;
    D) unlink=1 ;;
    *) echo "usage: $0 [-n] [-D] [package ...]" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
packages=("$@")
(( ${#packages[@]} )) || packages=("${DEFAULT_PACKAGES[@]}")

run() { if (( dry )); then echo "  $*"; else "$@"; fi; }

for pkg in "${packages[@]}"; do
  if [[ ! -d $DOTFILES/$pkg ]]; then
    echo "skip $pkg: no such package" >&2
    continue
  fi
  echo "== $pkg"
  # Skip compiled zsh files, editor state and downloaded plugins.
  while IFS= read -r -d '' src; do
    rel=${src#"$DOTFILES/$pkg/"}
    dest=$TARGET/$rel

    if (( unlink )); then
      if [[ -L $dest && $(readlink "$dest") == "$src" ]]; then
        echo "unlink $rel"
        run rm "$dest"
      fi
      continue
    fi

    if [[ -L $dest && $(readlink "$dest") == "$src" ]]; then
      continue
    fi
    if [[ -e $dest || -L $dest ]]; then
      echo "backup $rel -> $rel.bak"
      run mv "$dest" "$dest.bak"
    fi
    echo "link   $rel"
    run mkdir -p "$(dirname "$dest")"
    run ln -s "$src" "$dest"
  done < <(find "$DOTFILES/$pkg" -type f \
    -not -name '.DS_Store' \
    -not -name '*.zwc' \
    -not -path '*/.vim/undo/*' \
    -not -path '*/.vim/plugged/*' \
    -print0)
done
