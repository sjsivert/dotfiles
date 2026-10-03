# nix-darwin: the Mac itself. Command-line tools and terminal dotfiles come
# from home.nix, which Linux shares.
{ lib, pkgs, ... }:

let
  user = "sindre.sivertsen";

  lists = import ./packages {
    inherit lib;
    platform = pkgs.stdenv.hostPlatform;
  };

  # asmvik/formulae/yabai comes from the tap asmvik/formulae.
  taps = lib.unique (
    map (name: lib.concatStringsSep "/" (lib.take 2 (lib.splitString "/" name))) (
      builtins.filter (lib.hasInfix "/") (lists.brews ++ lists.casks)
    )
  );
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

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

  # Homebrew itself is installed by the README bootstrap. The formulae and
  # casks are listed in packages/brews.txt and packages/casks.txt.
  # cleanup = "none" leaves anything else installed; `pkg sync` asks about it.
  homebrew = {
    enable = true;
    onActivation.cleanup = "none";
    taps = map (name: {
      inherit name;
      trusted = true;
    }) taps;
    brews = lists.brews;
    casks = lists.casks;
  };

  # iTerm2 loads its settings from the repo (SETUP.md step 6).
  system.defaults.CustomUserPreferences."com.googlecode.iterm2" = {
    PrefsCustomFolder = "/Users/${user}/dotfiles/macos/iterm2";
    LoadPrefsFromCustomFolder = true;
  };
}
