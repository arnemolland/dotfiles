{ pkgs, ... }:

{
  imports = [
    ./profiles/cli.nix
    ./modules/openfang.nix
  ];

  home = {
    username = "arne";
    homeDirectory = "/home/arne";

    # Claude Code from pkgs.edge; nixpkgs' build disables self-updates, so
    # bump the nixpkgs-edge input to update it.
    packages = [ pkgs.edge.claude-code ];

    # Keep in sync with HM release version.
    stateVersion = "25.11";
  };
}
