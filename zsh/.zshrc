# ~/.local/bin first: ~/.zsh/*.zsh test for nvim, lsd and so on while they load.
# (hpc-tools.sh installs nvim, fzf, lazygit, ranger there on servers.)
typeset -U path PATH
[[ -d ~/.local/bin ]] && path=(~/.local/bin $path)

for config (~/.zsh/*.zsh) source $config


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sindre.sivertsen/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sindre.sivertsen/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sindre.sivertsen/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sindre.sivertsen/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Added by Antigravity
export PATH="/Users/sindre.sivertsen/.antigravity/antigravity/bin:$PATH"

zshaddhistory() {
  [[ $1 != *node-cdp* ]] && [[ $1 != *deferredMode* ]]
}

sshop() {
  local item="$1"; shift
  (( $# )) || set -- "$item"
  OP_SSH_ITEM="$item" SSH_ASKPASS="$HOME/.ssh/op-otp-askpass" \
  SSH_ASKPASS_REQUIRE=force ssh "$@"
}
