{ ... }:

{
  imports = [ ./profiles/cli.nix ];

  home = {
    username = "codespace";
    homeDirectory = "/home/codespace";

    # Keep in sync with HM release version.
    stateVersion = "25.11";
  };
}
