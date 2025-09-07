HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob nomatch
unsetopt beep notify
bindkey -e

# Speed up startup time
export skip_global_compinit=1

# FZF
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
# ctrl-r
export FZF_CTRL_R_OPTS='--no-sort --exact'
# Alt-c
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# Mac settings
#export GOPATH=$HOME/go
#export GOPATH=$HOME/go
#export GOROOT="$(brew --prefix golang)/libexec"
#export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

# bsdtar locale error fix
export  LANG=en_US.UTF-8

export LANG=en_US.UTF-8
export LC_MESSAGES="C"

# exported out on mac
#export BROWSER="/usr/bin/firefox"
# fzf options
# CTRL-T: automaticly selects if only 1 uitem. quits if 0
export FZF_CTRL_T_OPTS="--select-1 --exit-0"
# ALT-c tree command to get entries from dirs
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
# editor vim
export VISUAL=nvim
export EDITOR="$VISUAL"
#export TERMINAL=termite
export TERMINAL=alacritty
export TERM="xterm-256color"

LC_CTYPE="en_US.UTF-8"

export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
# Dotnet tools
export PATH="$PATH:/Users/sindre.sivertsen/.dotnet/tools"


# Export Android SDK path for Android Studio
export ANDROID_HOME=/Users/sindre.sivertsen/Library/Android/sdk
# ranger cd
function ranger-cd {
    tempfile="$(mktemp -t tmp.XXXXXX)"
    /usr/bin/ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}
bindkey -s '^O' 'ranger-cd\n'
#ranger-cd will fire for Ctrl+O

# WAL import for new terminals
# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
#(cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
#cat ~/.cache/wal/sequences


# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Autojump
[[ -s /Users/sindre.sivertsen/.autojump/etc/profile.d/autojump.sh ]] && source /Users/sindre.sivertsen/.autojump/etc/profile.d/autojump.sh



# Use correct ruby on mac
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

# Download Znap, if it's not there yet. For quick load times
[[ -r ~/.zsh-plugins/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/.zsh-plugins/znap
source ~/.zsh-plugins/znap/znap.zsh  # Start Znap

# `znap prompt` makes your prompt visible in just 15-40ms!
znap prompt sindresorhus/pure

# `znap eval` makes evaluating generated command output up to 10 times faster.
znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

# `znap function` lets you lazy-load features you don't always need.
znap function _pyenv pyenv "znap eval pyenv 'pyenv init - --no-rehash'"
compctl -K    _pyenv pyenv

znap clone https://github.com/wting/autojump.git

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

autoload -U compinit && compinit -u
