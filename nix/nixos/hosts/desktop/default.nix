{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  fonts = import ../../../lib/fonts.nix;
  fm = "/etc/nixos/private/fonts/berkeley-mono";
  fontEtc = lib.optionalAttrs (builtins.pathExists fm) (
    builtins.listToAttrs (map (name: {
      name = "fonts/local/${name}";
      value.source = "${fm}/${name}";
    }) fonts.berkeleyMonoFiles)
  );
in
{
  imports = [
    # Reusable modules — pick and choose per host
    ../../modules/desktop/base.nix
    ../../modules/desktop/environment.nix
    ../../modules/desktop/development.nix
    ../../modules/desktop/apps.nix
    ../../modules/desktop/gaming.nix
    ../../modules/desktop/github-runner.nix
    # Machine-specific hardware
    ./hardware-configuration.nix

    # ComfyUI
    inputs.comfyui-nix.nixosModules.default
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

  # Bootloader — EFI with Lanzaboote (Secure Boot)
  boot = {
    loader = {
      # Lanzaboote replaces systemd-boot as the bootloader.
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # Plymouth boot splash
    plymouth = {
      enable = true;
      theme = "lone";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "lone" ];
        })
      ];
    };

    # Silent boot — suppress firmware/kernel noise for a clean splash
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    kernelParams = [
      "amd_pstate=active"
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
  };

  # For debugging and troubleshooting Secure Boot
  environment.systemPackages = [ pkgs.sbctl ];

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

  # ComfyUI service (NVIDIA RTX 4080)
  services.comfyui = {
    enable = true;
    package = inputs.comfyui-nix.packages.${pkgs.stdenv.hostPlatform.system}.cuda;
    enableManager = true;
    port = 8188;
  };

  # Prevent KWin from bypassing the compositor for fullscreen windows
  # (direct scanout causes a black screen flash during mode renegotiation
  # on NVIDIA).  Negligible perf cost on RTX 4080.
  # VRR is set to "Always" via home-manager (plasma.nix) so the display
  # never mode-switches between fixed and variable refresh.
  environment.sessionVariables.KWIN_DRM_NO_DIRECT_SCANOUT = "1";

  system.stateVersion = "25.11";
}
