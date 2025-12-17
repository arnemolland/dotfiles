# dotfiles
Personal dotfiles for setting up a workable environment.

## Usage

First:

```bash
nix flake lock
```

For macOS:

```bash
sudo darwin-rebuild switch --flake .#<host>
```

For NixOS:
```bash
sudo nixos-rebuild switch --flake .#<host>
```
