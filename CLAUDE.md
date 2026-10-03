# dotfiles

Public repo: github.com/sjsivert/dotfiles. `flake.nix` sets up the Mac with
nix-darwin (`darwin.nix`) and Linux with standalone Home Manager. Both share
`home.nix`: command-line tools from nixpkgs, plus links from `~` into the
zsh, bash, git, tmux, vim, nvim, lazygit and nix packages.

The other top-level folders are GNU stow packages that mirror paths under
`$HOME`. `macos/` and the files in the repo root are not stowed.

- Setting up a new machine: follow SETUP.md (Mac) or README.md (Linux) with
  the user, one step at a time.
- Never commit credentials, tokens or anything from an employer. Grep the
  diff before every commit.
- Never stow a package that `home.nix` links.
- Stow `agents`, `vscode`, `cursor` and `zed` with `--no-folding`. `claude`
  and `karabiner` fold on purpose.
- Command-line tools go in `home.nix`. Casks, and formulae nixpkgs lacks for
  macOS, go in `darwin.nix`. There is no Brewfile.
- Check a change builds with `nix build '.#darwinConfigurations.mac.system'`.
  Applying it needs root, so the user runs
  `sudo darwin-rebuild switch --flake "$HOME/dotfiles#mac"`.
- Quote flake references: the zsh config sets `extendedglob`, which reads `#`
  as a glob. `git add` new `.nix` files, or Nix cannot see them.
