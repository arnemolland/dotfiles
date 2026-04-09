{
  description = "arnemolland/dotfiles (darwin + nixos)";

  inputs = {
    # Platform-specific nixpkgs
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-linux.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    hm-darwin.url = "github:nix-community/home-manager/release-25.11";
    hm-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    hm-linux.url = "github:nix-community/home-manager/release-25.11";
    hm-linux.inputs.nixpkgs.follows = "nixpkgs-linux";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-linux";
    };

    comfyui-nix.url = "github:utensils/comfyui-nix";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs-linux";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-linux";

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
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
    inputs@{
      darwin,
      hm-darwin,
      hm-linux,
      nixpkgs-linux,
      nixpkgs-unstable,
      ...
    }:
    let
      system = "aarch64-darwin"; # Apple Silicon
      linuxSystem = "x86_64-linux";

      # Shared overlay: custom packages + nixpkgs-unstable as pkgs.unstable
      mkOverlays = system: [
        (import ./nix/overlays)
        (_final: _prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ];
    in
    {
      darwinConfigurations.air = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = mkOverlays system;
          }

          ./nix/darwin/hosts/air.nix

          hm-darwin.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.arne = import ./nix/home/arne.nix;
            };
          }

          inputs.nix-homebrew.darwinModules.nix-homebrew
        ];
      };

      homeConfigurations.codespaces = hm-linux.lib.homeManagerConfiguration {
        pkgs = import nixpkgs-linux {
          system = linuxSystem;
          overlays = mkOverlays linuxSystem;
        };
        modules = [
          ./nix/home/codespaces.nix
        ];
      };

      nixosConfigurations.desktop = nixpkgs-linux.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { inherit inputs; };

        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = mkOverlays linuxSystem;
          }

          ./nix/nixos/hosts/desktop

          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.sops-nix.nixosModules.sops
          inputs.silentSDDM.nixosModules.default

          hm-linux.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.arne = import ./nix/home/arne.nix;
            };
          }
        ];
      };
    };
}
