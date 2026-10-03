{
  description = "Sindre's Mac and Linux setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      # Standalone Home Manager for Arch, Ubuntu and Debian.
      linuxHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [
            ./home.nix
            {
              home.username = "sjsivert";
              home.homeDirectory = "/home/sjsivert";
              programs.home-manager.enable = true;
              targets.genericLinux.enable = true;
              # `nix shell nixpkgs#…` and `pkg` get the nixpkgs this config
              # pins. nix-darwin does the same on the Mac.
              nix.registry.nixpkgs.flake = nixpkgs;
            }
          ];
        };
    in
    {
      # pkg switch, or: sudo darwin-rebuild switch --flake "$HOME/dotfiles#mac"
      darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
        ];
      };

      # pkg switch, or: home-manager switch --flake "$HOME/dotfiles"   (x86_64)
      #             or: home-manager switch --flake "$HOME/dotfiles#sjsivert-aarch64"
      homeConfigurations = {
        sjsivert = linuxHome "x86_64-linux";
        sjsivert-aarch64 = linuxHome "aarch64-linux";
      };
    };
}
