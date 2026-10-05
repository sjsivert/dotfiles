# dotfiles

Public repo: github.com/sjsivert/dotfiles. `flake.nix` sets up the Mac with
nix-darwin (`darwin.nix`) and Linux with standalone Home Manager. Both share
`home.nix`: command-line tools from nixpkgs, plus links from `~` into the
zsh, bash, git, tmux, vim, nvim, lazygit, zathura and nix packages.

`packages/` holds the package lists (`nix.txt`, `brews.txt`, `casks.txt`) and
the `pkg` script that edits them. `packages/default.nix` reads the lists.

The other top-level folders are GNU stow packages that mirror paths under
`$HOME`. `macos/`, `packages/` and the files in the repo root are not
stowed.

- Setting up a new machine: follow SETUP.md (Mac) or README.md (Linux) with
  the user, one step at a time.
- Never commit credentials, tokens or anything from an employer. Grep the
  diff before every commit.
- Never stow a package that `home.nix` links.
- Stow `agents`, `vscode`, `cursor` and `zed` with `--no-folding`. `claude`
  and `karabiner` fold on purpose.
- Command-line tools go in `packages/nix.txt`. Casks, and formulae nixpkgs
  lacks for macOS, go in `packages/casks.txt` and `brews.txt`. There is no
  Brewfile. `pkg add`, `rm`, `sync` and `up` commit their own changes.
- On the Mac, a switch needs the user's sudo password, which an agent cannot
  type. That rules out `pkg add`, `rm`, `up` and `switch` for an agent. Edit
  the list or `.nix` files instead, check the build with
  `nix build '.#darwinConfigurations.mac.system'`, ask the user to run
  `pkg switch`, then commit. `pkg switch` does not commit.
- Quote flake references: the zsh config sets `extendedglob`, which reads `#`
  as a glob. `git add` new `.nix` files, or Nix cannot see them.
