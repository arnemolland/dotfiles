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
- Claude Code: the official native install, which keeps itself on the latest
  release. The first `claude` run installs it into `~/.local/bin`.
- The Android SDK comes from the `nixpkgs-edge` input; update it with
  `nix flake update nixpkgs-edge`.
- `BROWSER=wslview` opens links (e.g. `gh auth login`) in the Windows browser;
  the Neovim clipboard goes through WSLg via `wl-clipboard`.

### iOS development (WSL)

The WSL profile ships Swift 6.4 (official toolchain, run in an FHS sandbox),
[xtool](https://xtool.sh), libimobiledevice (`ideviceinfo`, ...), usbmuxd and
CocoaPods.

- `swift`, `swiftc`, `sourcekit-lsp`, `lldb` work as usual; `swift-env` opens a
  shell inside the sandbox.
- Attach the iPhone from Windows with
  [usbipd-win](https://learn.microsoft.com/windows/wsl/connect-usb):
  `usbipd bind --busid <id>` once, then `usbipd attach --wsl --busid <id>`.
  Check with `ideviceinfo`.
- Run `xtool setup` once with Xcode 27's `Xcode.xip` downloaded.
- Bumping Swift or xtool: update the version and layer digest in
  `nix/pkgs/swift-toolchain.nix` / `nix/pkgs/xtool.nix` (see their comments).

### Android & Expo (WSL)

- Android SDK via `androidenv` (platforms 36/37, build-tools 36/37, NDK
  27.1, CMake 3.22.1), JDK 17, `ANDROID_HOME`/`JAVA_HOME` set. The SDK is
  read-only: if a project needs other versions, add them in
  `nix/nixos/modules/android.nix`.
- Metro over the tailnet: install Tailscale on the phone, then
  `npx expo start` in WSL. Shells export `REACT_NATIVE_PACKAGER_HOSTNAME` as
  the container's tailnet IP, so the QR code works as-is.
- Android over USB instead: attach it with usbipd, then
  `adb reverse tcp:8081 tcp:8081`.

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
