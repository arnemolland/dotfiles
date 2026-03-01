{ pkgs, ... }:
{
  # Desktop environment plumbing: audio, bluetooth, display portals, fonts.
  # Import this on any machine that drives a screen.

  services = {
    dbus.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      extraConfig = {
        pipewire."10-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 128;
            "default.clock.min-quantum" = 64;
            "default.clock.max-quantum" = 2048;
          };
        };
      };
    };
    blueman.enable = true;
  };

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts.monospace = [
    "Berkeley Mono"
    "Fira Code"
  ];
}
