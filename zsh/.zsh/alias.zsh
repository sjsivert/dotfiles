alias lyd="pavucontrol"
alias ssh="TERM=termite ssh"
alias pdf="zathura"
# .bashrc config
alias update='sudo pacmatic -Syu'
alias clock='tty-clock -c '
alias ls='ls --color=auto'
alias ll='ls -l'
# virtualenv
alias venv='source ~/.virtualenvs/abapong/bin/activate'
# the fuck
eval $(thefuck --alias)
# cd into dir when closing ranger
alias ranger='ranger-cd'
# trying to get correct wal colorscheme from rofi
#alias ranger='ranger-cd && cat ~/.cache/wal/sequences'
alias cc='pushd'
alias dirs="dirs -v"
alias v='nvim'
alias vim='nvim'
alias todo='topydo columns'
alias wall='QuickWall'
alias walb='wal -i ~/.QuickWall -b "#1D232F"'
alias td="topydo"
alias gap="git add -p"
# Go over and fix
alias co= "!git for-each-ref --format='%(refname:short)' refs/heads | fzf | xargs git checkout"
alias standup='{git -C ~/code/sio-event-calendar log --since 1.day --author sindrejohan1@gmail.no; git -C ~/code/sio-event-calendar log --since 1.day --author sindrejohan1@gmail.com} | cat'
alias dc="docker-compose"
# Wtf util Dashboard
alias wtf="wtfutil"
# Add todoist task
alias todo="todoist"
alias rebase="rebase --interactive"
alias grb="git rebase -i --autosquash"
