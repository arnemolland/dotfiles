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

## NixOS on WSL2

`nixosConfigurations.wsl` is the headless profile: the shared CLI/dev stack
(zsh, neovim, tmux, git, podman, toolchains) without desktop or bare-metal
config. It builds on [NixOS-WSL](https://github.com/nix-community/NixOS-WSL).

Fresh container (stock NixOS-WSL image, default user `nixos`):

```bash
nix-shell -p git --run 'git clone https://github.com/arnemolland/dotfiles ~/dotfiles'
cd ~/dotfiles
sudo nixos-rebuild boot --flake .#wsl
```

The profile renames the default user to `arne`, which needs one restart cycle
from PowerShell (`<distro>` is the WSL distro name, `NixOS` by default):

```powershell
wsl -t <distro>
wsl -d <distro> --user root exit
wsl -t <distro>
```

Then, inside the container as `arne`:

```bash
sudo mv /home/nixos/dotfiles ~ && sudo chown -R arne:users ~/dotfiles
sudo nixos-rebuild switch --flake ~/dotfiles   # hostname `wsl` selects .#wsl
```

Notes:
- Multiple containers can share `.#wsl`. For per-container tweaks, add
  `nixosConfigurations.<name> = mkWsl "<name>";` in `flake.nix`; the name is
  also the hostname.
- `git.nix` rewrites GitHub HTTPS to SSH and signs commits by default: add an
  SSH key and GPG key in the container before pushing.
- Remote access: run `sudo tailscale up --ssh --hostname <name>` once, then
  `ssh arne@<name>` from any device on the tailnet.
- `BROWSER=wslview` opens links (e.g. `gh auth login`) in the Windows browser;
  the Neovim clipboard goes through WSLg via `wl-clipboard`.

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
