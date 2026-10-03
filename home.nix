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
in
{
  home.stateVersion = "26.11";

  home.packages =
    with pkgs;
    [
      autojump
      bat
      bfg-repo-cleaner
      direnv
      docker-compose
      duckdb
      fd
      fzf
      gh
      git
      git-filter-repo
      gitui
      gotop
      htop
      imagemagick
      jq
      jump
      lazydocker
      lazygit
      lsd
      minikube
      neovim
      nixfmt
      nmap
      nodejs
      pandoc
      pnpm
      ranger
      ripgrep
      speedtest-cli
      starship
      stow
      tmux
      tree
      # LazyVim's nvim-treesitter (main branch) compiles parsers with it.
      tree-sitter
      uv
      watchman
      wget
      wtfutil
    ]
    # Not built for macOS; darwin.nix installs it with brew there.
    ++ lib.optionals stdenv.hostPlatform.isLinux [ tty-clock ];

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
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    # lazygit reads this on macOS and ~/.config/lazygit on Linux.
    "Library/Application Support/lazygit".source = link "lazygit/Library/Application Support/lazygit";
  };

  xdg.configFile = {
    "git".source = link "git/.config/git";
    "lazygit".source = link "lazygit/.config/lazygit";
    "nix/nix.conf".source = link "nix/.config/nix/nix.conf";
    "nvim".source = link "nvim/.config/nvim";
  };
}
