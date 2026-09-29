# New Mac setup

A runbook for an agent that walks the user through setting up a new Mac from
this repo. The user has already run the bootstrap in README.md: Homebrew,
Claude Code, this repo cloned to `~/dotfiles`, and the agent started there.

## How to run it

- Talk to the user in Norwegian. Keep it short.
- One step at a time: say what the step does, run it, run its check, then
  move on. Keep a todo per step so a restart can resume.
- Steps marked **[user]** need the user: a GUI, a password, a permission
  dialog or a sign-in. Say exactly what to click, then wait for "done".
- Never overwrite a file in `~`. When stow reports a conflict, show the
  existing file. Move it to `<name>.pre-dotfiles` only after the user agrees.
- This repo is public. Before any commit, grep the diff for credentials,
  tokens and anything from an employer, and leave those out.

## 0. Check the machine

```sh
echo "$HOME"; uname -m; sw_vers -productVersion; brew --version; ~/.local/bin/claude --version
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

Ask the user before editing, and commit the change.

## 1. Apps and tools

`Brewfile` lists taps, formulae, casks, VS Code extensions and go, npm, cargo
and uv globals. Some of it came from the previous job: Azure, Databricks,
MSSQL and Aspire tooling. Ask the user whether to drop any of it. If so,
delete those lines and commit.

```sh
brew bundle --file ~/dotfiles/Brewfile
```

**[user]** Some casks ask for the macOS password. The Brewfile has about 240
entries, so the run takes a while.
The `microsoft/aspire` tap prints a warning about its own cask definition;
ignore it.

Check: `brew bundle check --file ~/dotfiles/Brewfile`

## 2. Shell and command-line tools

```sh
cd ~/dotfiles && stow zsh git tmux nvim lazygit intellij yabai
```

Open a new terminal tab. On the first start, zsh clones znap, zinit, the
pure prompt and its other plugins by itself, so it needs network and takes a
minute. `zsh/.oh-my-zsh` is an empty leftover and nothing loads it.

Check: `zsh -ic 'echo ok'` prints `ok` without errors, and `which claude`
finds `~/.local/bin/claude`.

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

VS Code extensions come from the Brewfile. For Cursor:

**[user]** In Cursor, open the command palette and run the shell command
that installs `cursor` in PATH. Then:

```sh
xargs -n1 cursor --install-extension < ~/dotfiles/macos/cursor-extensions.txt
```

Check: `code --list-extensions | wc -l` (about 75) and
`cursor --list-extensions | wc -l` (about 61).

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

**[user]** In iTerm2: Settings → General → Settings → "Load settings from a
custom folder or URL" → `~/dotfiles/macos/iterm2`. Restart iTerm2.

If iTerm2 is not running, the agent can set the same thing itself:

```sh
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/dotfiles/macos/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
```

The Claude Code hooks call `~/.config/iterm2/cc-status`, a link into the
iTerm2 app. Create it:

```sh
mkdir -p ~/.config/iterm2
ln -s /Applications/iTerm.app/Contents/Resources/utilities/cc-status ~/.config/iterm2/cc-status
```

Check: `test -x ~/.config/iterm2/cc-status && echo ok`

## 7. Raycast

**[user]** Sign in to Google Drive (installed by the Brewfile) and open
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
