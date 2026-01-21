{ pkgs, ... }:

{
  imports = [
    ./modules/common.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/tmux.nix
    ./modules/neovim.nix
    ./modules/ghostty.nix
  ];

  home.username = "arne";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/arne" else "/home/arne";

  # pick the HM state version you start with and keep it
  home.stateVersion = "25.05";
}
