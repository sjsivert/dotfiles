# New Mac setup

A runbook for an agent that walks the user through setting up a new Mac from
this repo. The user has already run the bootstrap in README.md: Homebrew,
Nix, Claude Code, this repo cloned to `~/dotfiles`, and the agent started
there.

## How to run it

- Talk to the user in Norwegian. Keep it short.
- One step at a time: say what the step does, run it, run its check, then
  move on. Keep a todo per step so a restart can resume.
- Steps marked **[user]** need the user: a GUI, a password, a permission
  dialog or a sign-in. Say exactly what to click, then wait for "done".
- Never overwrite a file in `~`. When stow reports a conflict, show the
  existing file. Move it to `<name>.pre-dotfiles` only after the user agrees.
  Home Manager does this by itself for the files it links (step 1).
- Quote flake references, as in `"$HOME/dotfiles#mac"`. Once the repo's zsh
  config is linked, `extendedglob` reads `#` as a glob.
- This repo is public. Before any commit, grep the diff for credentials,
  tokens and anything from an employer, and leave those out.

## 0. Check the machine

```sh
echo "$HOME"; uname -m; sw_vers -productVersion; brew --version; nix --version; ~/.local/bin/claude --version
```

If `$HOME` is not `/Users/sindre.sivertsen`, some files still hardcode that
path. List them with
`grep -rlF /Users/sindre.sivertsen ~/dotfiles --exclude-dir=.git`:

- `zsh/.zshrc`, `zsh/.zsh/general.zsh` and the hook commands in
  `claude/.claude/settings.json`: replace the path with `$HOME`.
- The Cursor `settings.json`: replace it with the new absolute path.
- `macos/iterm2/com.googlecode.iterm2.plist`: fix the affected profile paths
  in iTerm2's settings after step 6, not in the file.
- `claude/.claude/plugins/*.json`: leave them. Claude Code rewrites them.
- `darwin.nix`: set `user` to the new username. The grep misses this file,
  because it builds `/Users/${user}` from that value.

Ask the user before editing, and commit the change.

## 1. Apps, tools and terminal dotfiles

One nix-darwin switch does all of this:

- `darwin.nix` installs the casks and formulae in `packages/casks.txt` and
  `packages/brews.txt`, and sets iTerm2 to load its settings from the repo.
- `home.nix` installs the command-line tools in `packages/nix.txt`, links
  zsh, bash, git, tmux, vim, nvim, lazygit, zathura and the nix config from
  `~` into the repo, and puts the `pkg` command in `~/.local/bin`.

`darwin-rebuild` is not installed yet, so build the system first and run it
from the build:

```sh
cd ~/dotfiles && nix --extra-experimental-features 'nix-command flakes' build '.#darwinConfigurations.mac.system'
```

The flag is only needed this once. After the switch, nix-darwin turns flakes
on in `/etc/nix/nix.conf`.

nix-darwin refuses to replace an `/etc` file whose content it does not
recognise, and the Nix installer edits some of them. When this was first
set up (2026-10-03), only `/etc/bashrc` needed moving. Show the user each file the
error names before moving it.

**[user]** These need the macOS password, and some casks ask for it too:

```sh
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo ./result/sw/bin/darwin-rebuild switch --flake "$HOME/dotfiles#mac"
```

If the switch stops with "Unexpected files in /etc", move each named file
the same way and run it again.

Open a new terminal tab. On the first start, zsh clones znap, zinit, the
pure prompt and its other plugins by itself, so it needs network and takes a
minute. `zsh/.oh-my-zsh` is an empty leftover and nothing loads it.

Check: `zsh -ic 'echo ok'` prints `ok` without errors, `which git nvim`
prints paths under `/etc/profiles/per-user/`, and `which claude` finds
`~/.local/bin/claude`.

## 2. Other stow packages

```sh
cd ~/dotfiles && stow intellij yabai
```

Do not stow the packages Home Manager links in step 1.

`git/.gitconfig` commits as the user's private address. If the new job needs
a different address for work repos, ask the user and set it per repo or with
an `includeIf` block.

## 3. SSH key and GitHub

```sh
ssh-keygen -t ed25519 -C "<ask the user which email>"
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "<machine name>"
git -C ~/dotfiles remote set-url origin git@github.com:sjsivert/dotfiles.git
```

**[user]** `gh auth login` opens a browser sign-in.

Check: `ssh -T git@github.com` greets the user, and
`git -C ~/dotfiles fetch` works.

## 4. Editors

```sh
cd ~/dotfiles && stow --no-folding vscode cursor zed
```

Always use `--no-folding` here. Without it, stow links whole app folders into
the repo and the apps write caches into it. If an editor was already opened,
its default `settings.json` conflicts; ask before moving it aside. The
`vscode` package also holds an old Linux `.config/Code - OSS` copy, which is
harmless.

No file in the repo lists the VS Code extensions any more. The old Brewfile
had 75 of them, and commit 770092f dropped them. Ask the user whether to
install them from `git show f19f995:Brewfile | grep '^vscode '`. For Cursor:

**[user]** In Cursor, open the command palette and run the shell command
that installs `cursor` in PATH. Then:

```sh
xargs -n1 cursor --install-extension < ~/dotfiles/macos/cursor-extensions.txt
```

Check: `cursor --list-extensions | wc -l` (about 59).

## 5. Keyboard and windows

```sh
cd ~/dotfiles && stow karabiner
yabai --start-service && skhd --start-service
```

`karabiner` folds on purpose, so `~/.config/karabiner` becomes one link.
Karabiner-Elements does not notice changes to a linked `karabiner.json`, so
the whole folder has to be the link. If Karabiner already created that folder, quit Karabiner,
move the folder aside (ask first), stow, then start Karabiner again.

**[user]** On first launch, approve Karabiner's driver extension and Input
Monitoring in System Settings. Grant yabai and skhd Accessibility access.

Check: a Karabiner remap works, and `yabai -m query --spaces` returns JSON.

## 6. iTerm2

Step 1 already pointed iTerm2 at `~/dotfiles/macos/iterm2`.

**[user]** If iTerm2 was open during step 1, quit and reopen it.

Check: `defaults read com.googlecode.iterm2 PrefsCustomFolder` prints the
repo path.

The Claude Code hooks call `~/.config/iterm2/cc-status`, a link into the
iTerm2 app. Create it:

```sh
mkdir -p ~/.config/iterm2
ln -s /Applications/iTerm.app/Contents/Resources/utilities/cc-status ~/.config/iterm2/cc-status
```

Check: `test -x ~/.config/iterm2/cc-status && echo ok`

## 7. Raycast

**[user]** Sign in to Google Drive (installed in step 1) and open
`My Drive/Personlig/Mac-oppsett/`. In Raycast, run "Import Settings & Data",
pick the `.rayconfig` file there and enter the password chosen at export. The
password is not in this repo; the user has it.

## 8. Claude Code config (last)

This step replaces `~/.claude`, which the running agent uses, so the user
does it outside the agent.

**[user]** Exit the agent, then run in a plain terminal:

```sh
mv ~/.claude ~/.claude.pre-dotfiles
cd ~/dotfiles && stow claude && stow --no-folding agents
claude
```

`claude` folds on purpose: `~/.claude` becomes a link to `claude/.claude`.
`agents` must not fold, or skill installers write into the repo.

In the new session, continue here:

- `claude doctor` reports no settings errors.
- `/plugin` shows the plugins listed under `enabledPlugins` in
  `claude/.claude/settings.json`. Install any that are missing.
- The skills in `claude/.claude/skills` are listed. The Azure skills from the
  old machine are not in the repo; ask the user whether to install them.
- When everything works, ask the user before deleting `~/.claude.pre-dotfiles`.

## Done

Summarise which steps ran, which were skipped, and anything that failed. Do
not push commits to the public repo without the user's OK.
