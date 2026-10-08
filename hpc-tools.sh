#!/usr/bin/env bash
# Installs the few command-line tools the dotfiles lean on into ~/.local, for
# a Linux x86_64 machine with no root and no Nix (e.g. the Olivia login node).
# Everything comes from a pinned GitHub release (or PyPI for ranger) and goes
# under ~/.local/opt, with links in ~/.local/bin.
#
#   ./hpc-tools.sh [-f] [tool ...]
#
#   -f  reinstall even when the pinned version is already there
#
# With no tools it installs all of them. Re-running is safe: a tool whose
# pinned version is already installed is skipped.
#
# Neovim also wants a C compiler for treesitter, so load a GCC module from
# NRIS/Login before its first start.

set -euo pipefail

# Pinned versions. Bump one, run the script again.
NVIM_VERSION=v0.12.5
FZF_VERSION=0.74.4
LAZYGIT_VERSION=0.66.0
RIPGREP_VERSION=15.2.0
FD_VERSION=v10.5.0
TREE_SITTER_VERSION=v0.26.11
RANGER_VERSION=1.9.4
PYTHON=${PYTHON:-python3.12}

ALL_TOOLS=(nvim fzf lazygit ripgrep fd tree-sitter ranger)

PREFIX=${PREFIX:-$HOME/.local}
BIN=$PREFIX/bin
OPT=$PREFIX/opt
STATE=$PREFIX/share/hpc-tools

force=0
while getopts "f" opt; do
  case $opt in
    f) force=1 ;;
    *) echo "usage: $0 [-f] [tool ...]" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
tools=("$@")
(( ${#tools[@]} )) || tools=("${ALL_TOOLS[@]}")

if [[ $(uname -s) != Linux || $(uname -m) != x86_64 ]]; then
  echo "This script installs Linux x86_64 binaries only." >&2
  exit 1
fi
for cmd in curl tar gzip; do
  command -v "$cmd" >/dev/null || { echo "missing: $cmd" >&2; exit 1; }
done

mkdir -p "$BIN" "$OPT" "$STATE"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# done_already NAME VERSION: true when this version is installed (and not -f).
done_already() {
  (( ! force )) && [[ -e $STATE/$1-$2 ]]
}
mark() {
  rm -f "$STATE/$1-"*
  touch "$STATE/$1-$2"
}
fetch() { curl -fsSL --retry 3 -o "$2" "$1"; }

install_nvim() {
  done_already nvim "$NVIM_VERSION" && { echo "nvim $NVIM_VERSION: already installed"; return; }
  echo "nvim $NVIM_VERSION"
  fetch "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz" "$tmp/nvim.tgz"
  rm -rf "$OPT/nvim-$NVIM_VERSION"
  mkdir -p "$OPT/nvim-$NVIM_VERSION"
  tar -xzf "$tmp/nvim.tgz" -C "$OPT/nvim-$NVIM_VERSION" --strip-components=1
  ln -sfn "$OPT/nvim-$NVIM_VERSION/bin/nvim" "$BIN/nvim"
  mark nvim "$NVIM_VERSION"
}

install_fzf() {
  done_already fzf "$FZF_VERSION" && { echo "fzf $FZF_VERSION: already installed"; return; }
  echo "fzf $FZF_VERSION"
  fetch "https://github.com/junegunn/fzf/releases/download/v$FZF_VERSION/fzf-$FZF_VERSION-linux_amd64.tar.gz" "$tmp/fzf.tgz"
  tar -xzf "$tmp/fzf.tgz" -C "$tmp" fzf
  install -m 755 "$tmp/fzf" "$BIN/fzf"
  mark fzf "$FZF_VERSION"
}

install_lazygit() {
  done_already lazygit "$LAZYGIT_VERSION" && { echo "lazygit $LAZYGIT_VERSION: already installed"; return; }
  echo "lazygit $LAZYGIT_VERSION"
  fetch "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_${LAZYGIT_VERSION}_linux_x86_64.tar.gz" "$tmp/lazygit.tgz"
  tar -xzf "$tmp/lazygit.tgz" -C "$tmp" lazygit
  install -m 755 "$tmp/lazygit" "$BIN/lazygit"
  mark lazygit "$LAZYGIT_VERSION"
}

install_ripgrep() {
  done_already ripgrep "$RIPGREP_VERSION" && { echo "ripgrep $RIPGREP_VERSION: already installed"; return; }
  echo "ripgrep $RIPGREP_VERSION"
  local dir=ripgrep-$RIPGREP_VERSION-x86_64-unknown-linux-musl
  fetch "https://github.com/BurntSushi/ripgrep/releases/download/$RIPGREP_VERSION/$dir.tar.gz" "$tmp/rg.tgz"
  tar -xzf "$tmp/rg.tgz" -C "$tmp" "$dir/rg"
  install -m 755 "$tmp/$dir/rg" "$BIN/rg"
  mark ripgrep "$RIPGREP_VERSION"
}

install_fd() {
  done_already fd "$FD_VERSION" && { echo "fd $FD_VERSION: already installed"; return; }
  echo "fd $FD_VERSION"
  local dir=fd-$FD_VERSION-x86_64-unknown-linux-musl
  fetch "https://github.com/sharkdp/fd/releases/download/$FD_VERSION/$dir.tar.gz" "$tmp/fd.tgz"
  tar -xzf "$tmp/fd.tgz" -C "$tmp" "$dir/fd"
  install -m 755 "$tmp/$dir/fd" "$BIN/fd"
  mark fd "$FD_VERSION"
}

install_tree_sitter() {
  done_already tree-sitter "$TREE_SITTER_VERSION" && { echo "tree-sitter $TREE_SITTER_VERSION: already installed"; return; }
  echo "tree-sitter $TREE_SITTER_VERSION"
  fetch "https://github.com/tree-sitter/tree-sitter/releases/download/$TREE_SITTER_VERSION/tree-sitter-linux-x64.gz" "$tmp/ts.gz"
  gzip -dc "$tmp/ts.gz" > "$tmp/tree-sitter"
  install -m 755 "$tmp/tree-sitter" "$BIN/tree-sitter"
  mark tree-sitter "$TREE_SITTER_VERSION"
}

install_ranger() {
  done_already ranger "$RANGER_VERSION" && { echo "ranger $RANGER_VERSION: already installed"; return; }
  echo "ranger $RANGER_VERSION"
  command -v "$PYTHON" >/dev/null || { echo "ranger: $PYTHON not found (set PYTHON=...)" >&2; return 1; }
  rm -rf "$OPT/ranger-venv"
  "$PYTHON" -m venv "$OPT/ranger-venv"
  "$OPT/ranger-venv/bin/pip" install --quiet --disable-pip-version-check "ranger-fm==$RANGER_VERSION"
  ln -sfn "$OPT/ranger-venv/bin/ranger" "$BIN/ranger"
  mark ranger "$RANGER_VERSION"
}

for tool in "${tools[@]}"; do
  case $tool in
    nvim|neovim) install_nvim ;;
    fzf) install_fzf ;;
    lazygit) install_lazygit ;;
    ripgrep|rg) install_ripgrep ;;
    fd) install_fd ;;
    tree-sitter) install_tree_sitter ;;
    ranger) install_ranger ;;
    *) echo "unknown tool: $tool (known: ${ALL_TOOLS[*]})" >&2; exit 2 ;;
  esac
done

case ":$PATH:" in
  *":$BIN:"*) ;;
  *) echo "note: $BIN is not on your PATH yet" ;;
esac
