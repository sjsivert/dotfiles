zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

function zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
}
# FZF
# Set up fzf key bindings and fuzzy completion
# Needs to be after zsh-vi-mode to work
source <(fzf --zsh)

