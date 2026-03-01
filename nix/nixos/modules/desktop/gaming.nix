{ pkgs, ... }:
{
  # Gaming: Steam, Proton helpers, performance overlays.
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
