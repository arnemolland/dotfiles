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

## Desktop with NixOS

Fresh install steps (EFI, LUKS+btrfs assumed):
1) On the target machine after partitioning/mounting: `nixos-generate-config --show-hardware-config > nix/nixos/hosts/desktop/hardware-configuration.nix`
2) Copy this repo to the machine (or mount it) and run: `sudo nixos-install --flake .#desktop`
3) After edits: `sudo nixos-rebuild switch --flake .#desktop`
4) Quick sanity: `nix flake check` or `nix eval .#nixosConfigurations.desktop.config.system.stateVersion`

Notes:
- Hyprland enabled via `programs.hyprland` with greetd autologin to user `arne`.
- NVIDIA proprietary driver with 32-bit OpenGL for Steam/Proton.
- Gaming tools: Steam (gamescope session), Gamemode, ProtonUp-Qt, Heroic, Lutris, Wine.
- Berkeley Mono (private): copy all `.otf` files to `/etc/nixos/private/fonts/berkeley-mono/` on the machine. The configuration will map them into `fonts/local/` if that directory exists. Ghostty and fontconfig default to `Berkeley Mono` when present. For macOS/air, drop the `.otf` files into `~/.local/share/fonts/berkeley-mono/` (gitignored/local).
