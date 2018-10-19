#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# oh my git
#source ~/.config/git/oh-my-git.sh

alias ls='ls --color=auto'
alias ll='ls -l'
# the fuck
eval $(thefuck --alias)
#PS1='[\u@\h \W]\$ '
export PS1="\[\033[38;5;26m\][\[$(tput sgr0)\]\[\033[38;5;32m\]\u\[$(tput sgr0)\]\[\033[38;5;31m\]@\[$(tput sgr0)\]\[\033[38;5;33m\]\h\[$(tput sgr0)\]\[\033[38;5;32m\]:\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;31m\]\w\[$(tput sgr0)\]\[\033[38;5;33m\]]\[$(tput sgr0)\]"

# git completion
. ~/.config/git/git-completion.bash
# git status 
. ~/.config/git/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1

 #transparency i xterm
#[ -n "$XTERM_VERSION" ] && transset-df --id "$WINDOWID" >/dev/null

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
