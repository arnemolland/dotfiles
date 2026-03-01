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

  home = {
    username = "arne";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/arne" else "/home/arne";

    # Must match the HM release each platform was first deployed with.
    stateVersion = if pkgs.stdenv.isDarwin then "25.05" else "25.11";
  };
}
