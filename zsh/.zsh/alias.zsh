alias lyd="pavucontrol"
alias ssh="TERM=xterm-256color ssh"
alias pdf="zathura"
# .bashrc config
alias update='sudo pacmatic -Syu'
alias clock='tty-clock -c '
alias ls='ls --color=auto'
alias ll='ls -l'
# virtualenv
alias venv='source ~/.virtualenvs/abapong/bin/activate'
# the fuck
# cd into dir when closing ranger
#alias ranger='ranger-cd'
# trying to get correct wal colorscheme from rofi
#alias ranger='ranger-cd && cat ~/.cache/wal/sequences'
alias cc='pushd'
alias dirs="dirs -v"
if command -v nvim >/dev/null 2>&1; then
  alias v='nvim'
  alias vim='nvim'
else
  alias v='vim'
fi
alias todo='topydo columns'
alias wall='QuickWall'
alias walb='wal -i ~/.QuickWall -b "#1D232F"'
alias td="topydo"
alias gap="git add -p"
# Go over and fix
alias co= "!git for-each-ref --format='%(refname:short)' refs/heads | fzf | xargs git checkout"
alias standup='{git -C . log --since 1.day --author sindrejohan1@gmail.com; git -C . log --since 1.day --author sindre.sivertsen@noaignite.com} | cat'
alias dc="docker compose"
# Wtf util Dashboard
alias wtf="wtfutil"
# Add todoist task
alias todo="todoist"
alias rebase="rebase --interactive"
alias grb="git rebase -i --autosquash"
alias cheat='f() { curl cht.sh/"$@";}; f'
alias gan="git add -N . && git add -p"
alias glogm="glog --merges --first-parent"
mkd() {
mkdir -p "$@" && cd "$@"
}
alias ranger="source ranger"
alias jmp="jump"
alias ld="lazydocker"
if command -v lsd >/dev/null 2>&1; then
  alias la="lsd -la"
else
  alias la="ls -la"
fi
alias flush="docker compose exec -it redis redis-cli FLUSHALL"
alias claudeyolo="CLAUDE_CODE_NO_FLICKER=1 claude --dangerously-skip-permissions"
alias claude="CLAUDE_CODE_NO_FLICKER=1 claude"
alias claudesafe="CLAUDE_CODE_NO_FLICKER=1 claude --sandbox"
alias lgs="node ~/code/gitreview/bin/gitreview.js"



