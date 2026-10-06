_:

{
  imports = [
    ./profiles/cli.nix
    ./modules/openfang.nix
  ];

  home = {
    username = "arne";
    homeDirectory = "/home/arne";

    # Keep in sync with HM release version.
    stateVersion = "25.11";
  };
}
