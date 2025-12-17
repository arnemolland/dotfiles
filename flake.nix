{
  description = "arnemolland/dotfiles (nix-darwin)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Pinned taps
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-supabase = { url = "github:supabase/homebrew-tap"; flake = false; };
    homebrew-bun = { url = "github:oven-sh/homebrew-bun"; flake=false; };
  };

  outputs = inputs@{ self, darwin, home-manager, nixpkgs, ... }:
  let
    system = "aarch64-darwin"; # Apple Silicon
    # system = "x86_64-darwin"; # Intel
  in
  {
    darwinConfigurations.air = darwin.lib.darwinSystem {
      inherit system;

      # Allow modules to reference inputs.homebrew-core, etc.
      specialArgs = { inherit inputs; };

      modules = [
        ./nix/darwin/hosts/air.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.arne = import ./nix/home/arne.nix;
        }

        inputs.nix-homebrew.darwinModules.nix-homebrew
      ];
    };
  };
}
