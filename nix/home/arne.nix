{ pkgs, ... }:

{
  imports = [
    ./profiles/cli.nix
    ./modules/ghostty.nix
    ./modules/openchamber.nix
    ./modules/openfang.nix
    ./modules/plasma.nix
  ];

  home = {
    username = "arne";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/arne" else "/home/arne";

    # Must match the HM release each platform was first deployed with.
    stateVersion = if pkgs.stdenv.isDarwin then "25.05" else "25.11";
  };
}
