let configs = [
\  "general",
\  "ui",
\  "commands",
\  "plugins",
\  "plugin-settings",
\  "coc"
\]
for file in configs
  let x = expand("~/.vim/".file.".vim")
  if filereadable(x)
    execute 'source' x
  endif
endfor
