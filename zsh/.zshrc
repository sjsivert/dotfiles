for config (~/.zsh/*.zsh) source $config


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sindre.sivertsen/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sindre.sivertsen/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sindre.sivertsen/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sindre.sivertsen/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Added by Antigravity
export PATH="/Users/sindre.sivertsen/.antigravity/antigravity/bin:$PATH"
