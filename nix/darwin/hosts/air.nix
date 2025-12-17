{ ... }:

{
  networking.hostName = "air";

  system.primaryUser = "arne";

  users.users.arne.home = "/Users/arne";

  imports = [
    ../modules/base.nix
    ../modules/nix-homebrew.nix
    ../modules/homebrew.nix
  ];

  system.stateVersion = 6;
}
