# Terminal environment shared by every home profile: shell, editor, git, tools.
_:

{
  imports = [
    ../modules/common.nix
    ../modules/git.nix
    ../modules/zsh.nix
    ../modules/tmux.nix
    ../modules/neovim.nix
  ];
}
