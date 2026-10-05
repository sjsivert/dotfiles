# Home Manager: terminal tools and dotfiles, shared by the Mac and Linux.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Link into the repo checkout rather than a copy in the Nix store, so edits
  # apply without a rebuild, like stow. The repo must be cloned to ~/dotfiles.
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";

  lists = import ./packages {
    inherit lib;
    platform = pkgs.stdenv.hostPlatform;
  };
in
{
  home.stateVersion = "26.11";

  # The tools are listed in packages/nix.txt.
  home.packages = map (name: lib.getAttrFromPath (lib.splitString "." name) pkgs) lists.nix;

  # These were stow packages. Mac app configs (karabiner, yabai, zed, vscode,
  # cursor, claude, agents) are still stowed; see SETUP.md.
  home.file = {
    ".zshrc".source = link "zsh/.zshrc";
    ".zsh".source = link "zsh/.zsh";
    ".bashrc".source = link "bash/.bashrc";
    ".gitconfig".source = link "git/.gitconfig";
    ".tmux.conf".source = link "tmux/.tmux.conf";
    ".vimrc".source = link "vim/.vimrc";
    ".vim".source = link "vim/.vim";
    ".local/bin/pkg".source = link "packages/pkg";
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    # lazygit reads its config from here on macOS, so point it at the same
    # folder Linux reads through ~/.config/lazygit.
    "Library/Application Support/lazygit".source = link "lazygit/.config/lazygit";
  };

  xdg.configFile = {
    "git".source = link "git/.config/git";
    "lazygit".source = link "lazygit/.config/lazygit";
    "nix/nix.conf".source = link "nix/.config/nix/nix.conf";
    "nvim".source = link "nvim/.config/nvim";
    "ranger".source = link "ranger/.config/ranger";
    "zathura".source = link "zathura/.config/zathura";
  };
}
