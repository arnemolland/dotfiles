{
  description = "arnemolland/dotfiles (darwin + nixos)";

  inputs = {
    # Platform-specific nixpkgs
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-linux.url = "github:NixOS/nixpkgs/nixos-25.11";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    hm-darwin.url = "github:nix-community/home-manager/release-25.05";
    hm-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    hm-linux.url = "github:nix-community/home-manager/release-25.11";
    hm-linux.inputs.nixpkgs.follows = "nixpkgs-linux";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-linux";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Pinned taps
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-supabase = {
      url = "github:supabase/homebrew-tap";
      flake = false;
    };
    homebrew-bun = {
      url = "github:oven-sh/homebrew-bun";
      flake = false;
    };
  };

  outputs =
    inputs@{ self
    , darwin
    , hm-darwin
    , hm-linux
    , nixpkgs-darwin
    , nixpkgs-linux
    , ...
    }:
    let
      system = "aarch64-darwin"; # Apple Silicon
      # system = "x86_64-darwin"; # Intel
      linuxSystem = "x86_64-linux";
    in
    {
      darwinConfigurations.air = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          ./nix/darwin/hosts/air.nix

          hm-darwin.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.arne = import ./nix/home/arne.nix;
          }

          inputs.nix-homebrew.darwinModules.nix-homebrew
        ];
      };

      homeConfigurations.codespaces = hm-linux.lib.homeManagerConfiguration {
        pkgs = import nixpkgs-linux { system = linuxSystem; };
        modules = [
          ./nix/home/codespaces.nix
        ];
      };

      nixosConfigurations.desktop = nixpkgs-linux.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { inherit inputs; };

        modules = [
          ./nix/nixos/hosts/desktop

          hm-linux.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.arne = import ./nix/home/arne.nix;
          }
        ];
      };
    };
}
