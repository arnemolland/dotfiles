{ pkgs, inputs, ... }:
{
  # Graphical desktop applications.
  # Skip this module on headless or server hosts.

  # Prefer Wayland where supported (Electron apps via Ozone).
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    ghostty
    zed-editor
    podman-desktop
    spotify
    discord
    slack
    obsidian
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
