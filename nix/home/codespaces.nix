{ pkgs, ... }:

{
  imports = [
    ./modules/common.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/tmux.nix
    ./modules/neovim.nix
  ];

  home.username = "codespace";
  home.homeDirectory = "/home/codespace";

  # Keep in sync with HM release version.
  home.stateVersion = "25.11";
}
