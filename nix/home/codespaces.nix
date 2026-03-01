{ ... }:

{
  imports = [
    ./modules/common.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/tmux.nix
    ./modules/neovim.nix
  ];

  home = {
    username = "codespace";
    homeDirectory = "/home/codespace";

    # Keep in sync with HM release version.
    stateVersion = "25.11";
  };
}
