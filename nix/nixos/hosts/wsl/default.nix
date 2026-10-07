{ pkgs, ... }:

{
  # Headless NixOS on WSL2: the shared CLI/dev stack without desktop or
  # bare-metal concerns (bootloader, GPU, networking, SSH are Windows' job).
  # networking.hostName is set per instance by mkWsl in flake.nix.
  imports = [
    ../../modules/common/base.nix
    ../../modules/common/development.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "arne";
  };

  home-manager.backupFileExtension = "bak";

  # No password is set on WSL; NixOS-WSL defaults to passwordless sudo.
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;

  # Own tailnet node so other devices can reach the container directly.
  # Join once with `sudo tailscale up --ssh --hostname <name>`.
  services.tailscale.enable = true;

  # Hand URLs (gh auth login, xdg-open) to the Windows browser.
  environment.sessionVariables.BROWSER = "wslview";

  environment.systemPackages = with pkgs; [
    wslu # wslview, wslpath helpers
    wl-clipboard # Neovim clipboard via WSLg
  ];

  system.stateVersion = "25.11";
}
