HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob nomatch
unsetopt beep notify
bindkey -e

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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

# To add support for TTYs this line can be optionally added.
#source ~/.cache/wal/colors-tty.sh

