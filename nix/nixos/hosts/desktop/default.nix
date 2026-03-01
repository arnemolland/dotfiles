{
  config,
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
    # Reusable modules — pick and choose per host
    ../../modules/desktop/base.nix
    ../../modules/desktop/environment.nix
    ../../modules/desktop/development.nix
    ../../modules/desktop/apps.nix
    ../../modules/desktop/gaming.nix
    # Machine-specific hardware
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  home-manager.backupFileExtension = "bak";

  # X server (Wayland primary via SDDM/Plasma 6, X enabled for compat)
  # NVIDIA RTX 4080
  # KDE Plasma (Wayland) with SDDM
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    power-profiles-daemon.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = false;
    };
    desktopManager.plasma6.enable = true;
  };

  # Bootloader — EFI; LUKS/btrfs in hardware-configuration.nix
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
    };
    # Ryzen 9 power/perf
    kernelParams = [
      "amd_pstate=active"
      "nvidia-drm.modeset=1"
    ];
  };

  # NVIDIA RTX 4080
  hardware = {
    bluetooth = {
      enable = true;
      settings.General.Experimental = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Private Berkeley Mono font mapping
  environment.etc = fontEtc;

  system.stateVersion = "25.11";
}
