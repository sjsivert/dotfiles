# dotfiles

My macOS setup, as GNU stow packages that mirror paths under `$HOME`. The
i3, sway, rofi, termite and other X11 packages are from an old Arch Linux
machine and are not used on the Mac.

## New Mac

[SETUP.md](SETUP.md) is a runbook for an agent: it walks me through the whole
setup one step at a time. To start it:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
curl -fsSL https://claude.ai/install.sh | bash
git clone https://github.com/sjsivert/dotfiles.git ~/dotfiles
cd ~/dotfiles && ~/.local/bin/claude
```

Then ask it to set up the machine from SETUP.md.

## Not in this repo

- **Raycast settings.** A password-protected export (`.rayconfig`, 2026-09-29)
  is in my Google Drive under `My Drive/Personlig/Mac-oppsett/`. It stays out of
  this repo because the repo is public. The password is the one I chose at
  export; it is not written down here.
- **Anything from an employer.** Work settings, skills, credentials and tokens
  never go in here.

## Old Arch Linux setup

![screenshot](screenshot.png)
