{ pkgs, ... }:
{
  # Gaming: Steam, Proton helpers, performance overlays, game streaming.
  # Omit this module on work-only or low-spec machines.

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    gamescope = {
      enable = true;
      args = [ "--hdr-enabled" ];
    };
    gamemode.enable = true;
  };

  # Sunshine — game streaming host (pair with Moonlight on client devices).
  # First-time setup: visit https://localhost:47990 in a browser to set credentials.
  # Sunshine can create a virtual display for streaming with the monitor off.
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Fix /dev/uinput permissions so Sunshine (running as user) can create
  # virtual input devices for keyboard/mouse passthrough.
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
  '';

  environment.systemPackages = with pkgs; [
    mangohud
    vkbasalt
    nvtopPackages.full
    protonup-qt
    heroic
    lutris
    wineWowPackages.stable
  ];
}
