# nix-darwin: the Mac itself. Command-line tools and terminal dotfiles come
# from home.nix, which Linux shares.
{ lib, ... }:

let
  user = "sindre.sivertsen";
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.primaryUser = user;
  system.stateVersion = 7;

  users.users.${user}.home = "/Users/${user}";

  # nix-darwin writes /etc/zshrc. ~/.zsh runs compinit and sets the pure
  # prompt itself, and the stock macOS file did not share history.
  programs.zsh = {
    enableGlobalCompInit = false;
    promptInit = "";
    interactiveShellInit = "unsetopt SHARE_HISTORY HIST_IGNORE_DUPS";
  };

  # nix-darwin's /etc/zprofile skips macOS's path_helper, which is what put
  # Homebrew on PATH. Keep it after Apple's paths, as before.
  environment.systemPath = lib.mkAfter [ "/opt/homebrew/bin" ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Files Home Manager finds in its way, such as old stow links, are kept
    # with this suffix.
    backupFileExtension = "pre-dotfiles";
    users.${user} = import ./home.nix;
  };

  # Homebrew itself is installed by the README bootstrap. This replaces the
  # Brewfile: GUI apps, plus formulae that nixpkgs lacks or that must come
  # from brew on macOS. cleanup = "none" leaves anything else installed.
  homebrew = {
    enable = true;
    onActivation.cleanup = "none";

    taps = [
      {
        name = "asmvik/formulae";
        trusted = true;
      }
    ];

    brews = [
      "python@3.10"
      "nvm"
      "mdless"
      "telnet"
      "tty-clock"
      "wtf"
      "asmvik/formulae/skhd"
      "asmvik/formulae/yabai"
    ];

    casks = [
      "1password"
      "1password-cli"
      "anki"
      "chatgpt"
      "claude"
      "cleanshot"
      "discord"
      "flux-app"
      "font-hack-nerd-font"
      "font-jetbrains-mono"
      "font-monaspace"
      "go2shell"
      "google-chrome"
      "google-drive"
      "homerow"
      "iterm2"
      "karabiner-elements"
      "keepingyouawake"
      "keycastr"
      "macfuse"
      "notion"
      "obsidian"
      "openvpn-connect"
      "orbstack"
      "raycast"
      "scroll-reverser"
      "shottr"
      "slack"
      "spotify"
      "swish"
      "tailscale-app"
      "todoist-app"
      "visual-studio-code"
      "xnapper"
      "zed"
    ];
  };

  # iTerm2 loads its settings from the repo (SETUP.md step 6).
  system.defaults.CustomUserPreferences."com.googlecode.iterm2" = {
    PrefsCustomFolder = "/Users/${user}/dotfiles/macos/iterm2";
    LoadPrefsFromCustomFolder = true;
  };
}
