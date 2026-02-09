{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  fm = "/etc/nixos/private/fonts/berkeley-mono";
  fontEtc = lib.optionalAttrs (builtins.pathExists fm) {
    "fonts/local/BerkeleyMono-Thin.otf".source = "${fm}/BerkeleyMono-Thin.otf";
    "fonts/local/BerkeleyMono-Thin-Oblique.otf".source = "${fm}/BerkeleyMono-Thin-Oblique.otf";
    "fonts/local/BerkeleyMono-ExtraLight.otf".source = "${fm}/BerkeleyMono-ExtraLight.otf";
    "fonts/local/BerkeleyMono-ExtraLight-Oblique.otf".source =
      "${fm}/BerkeleyMono-ExtraLight-Oblique.otf";
    "fonts/local/BerkeleyMono-Light.otf".source = "${fm}/BerkeleyMono-Light.otf";
    "fonts/local/BerkeleyMono-Light-Oblique.otf".source = "${fm}/BerkeleyMono-Light-Oblique.otf";
    "fonts/local/BerkeleyMono-SemiLight.otf".source = "${fm}/BerkeleyMono-SemiLight.otf";
    "fonts/local/BerkeleyMono-SemiLight-Oblique.otf".source =
      "${fm}/BerkeleyMono-SemiLight-Oblique.otf";
    "fonts/local/BerkeleyMono-Regular.otf".source = "${fm}/BerkeleyMono-Regular.otf";
    "fonts/local/BerkeleyMono-Oblique.otf".source = "${fm}/BerkeleyMono-Oblique.otf";
    "fonts/local/BerkeleyMono-Medium.otf".source = "${fm}/BerkeleyMono-Medium.otf";
    "fonts/local/BerkeleyMono-Medium-Oblique.otf".source = "${fm}/BerkeleyMono-Medium-Oblique.otf";
    "fonts/local/BerkeleyMono-SemiBold.otf".source = "${fm}/BerkeleyMono-SemiBold.otf";
    "fonts/local/BerkeleyMono-SemiBold-Oblique.otf".source = "${fm}/BerkeleyMono-SemiBold-Oblique.otf";
    "fonts/local/BerkeleyMono-Bold.otf".source = "${fm}/BerkeleyMono-Bold.otf";
    "fonts/local/BerkeleyMono-Bold-Oblique.otf".source = "${fm}/BerkeleyMono-Bold-Oblique.otf";
    "fonts/local/BerkeleyMono-ExtraBold.otf".source = "${fm}/BerkeleyMono-ExtraBold.otf";
    "fonts/local/BerkeleyMono-ExtraBold-Oblique.otf".source =
      "${fm}/BerkeleyMono-ExtraBold-Oblique.otf";
    "fonts/local/BerkeleyMono-Black.otf".source = "${fm}/BerkeleyMono-Black.otf";
    "fonts/local/BerkeleyMono-Black-Oblique.otf".source = "${fm}/BerkeleyMono-Black-Oblique.otf";
  };
in
{
  imports = [
    ../../modules/common-desktop.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  home-manager.backupFileExtension = "bak";

  # X server toggle (Wayland primary via SDDM/Plasma 6, but enable X for compatibility)
  services.xserver.enable = true;

  # Bootloader expects EFI; LUKS/btrfs reside in hardware-configuration.nix generated on the target.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Ryzen 9 power/perf defaults
  boot.kernelParams = [
    "amd_pstate=active"
    "nvidia-drm.modeset=1"
  ];
  services.power-profiles-daemon.enable = true;

  # NVIDIA setup for RTX 4080
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    bluetooth = {
      enable = true;
      settings.General.Experimental = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true; # needed for Steam/Proton
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true; # desktop: avoid deep sleep quirks
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # KDE Plasma (Wayland) with SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  programs.gamescope = {
    enable = true;
    args = [ "--hdr-enabled" ];
  };

  # Gaming stack
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    protonup-qt
    heroic
    lutris
    wineWowPackages.stable
    slack
    dbpro
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Prefer Wayland where supported (e.g., Slack via Ozone).
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Optional font mapping for private Berkeley Mono
  environment.etc = fontEtc;
}
