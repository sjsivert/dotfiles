# dotfiles

Public repo: github.com/sjsivert/dotfiles. Each top-level folder is a GNU
stow package that mirrors paths under `$HOME`. `macos/` and the files in the
repo root are not stowed.

- Setting up a new machine: follow SETUP.md with the user, one step at a time.
- Never commit credentials, tokens or anything from an employer. Grep the
  diff before every commit.
- Stow `agents`, `vscode`, `cursor` and `zed` with `--no-folding`.
  `claude` and `karabiner` fold on purpose.
