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
    builtins.listToAttrs (
      map (name: {
        name = "fonts/local/${name}";
        value.source = "${fm}/${name}";
      }) fonts.berkeleyMonoFiles
    )
  );

  wallpaper = ../../../../wallpapers/big-sur-night.jpg;
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

  # KDE Plasma (Wayland) with SDDM + SilentSDDM theme
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    # SilentSDDM sets wayland.enable = !xserver.enable, which wrongly
    # falls back to X11 here.  Force Wayland so the SDDM greeter and
    # KWin share the same display server — no black-screen gap.
    displayManager.sddm = {
      wayland.enable = lib.mkForce true;
      # HiDPI scaling for the SDDM greeter (4K / 3840x2160)
      settings = {
        Wayland.EnableHiDPI = true;
        X11.EnableHiDPI = true;
        # Merge SilentSDDM's required QML import path with HiDPI env vars.
        # SilentSDDM hardcodes GreeterEnvironment, so mkForce is needed.
        General.GreeterEnvironment = lib.mkForce (builtins.concatStringsSep "," [
          "QML2_IMPORT_PATH=${config.programs.silentSDDM.package'}/share/sddm/themes/silent/components/"
          "QT_IM_MODULE=qtvirtualkeyboard"
          "QT_SCREEN_SCALE_FACTORS=2"
          "QT_FONT_DPI=192"
        ]);
      };
    };
    power-profiles-daemon.enable = true;
    desktopManager.plasma6.enable = true;
  };

  # SilentSDDM login screen with Big Sur wallpaper
  programs.silentSDDM = {
    enable = true;
    theme = "default";
    backgrounds.big-sur = wallpaper;
    settings = {
      "LoginScreen" = {
        background = "big-sur-night.jpg";
        blur = 0;
        brightness = 0.0;
        saturation = 0.0;
      };
      "LockScreen" = {
        background = "big-sur-night.jpg";
        blur = 32;
        brightness = 0.0;
        saturation = 0.0;
      };
    };
  };

  # Bootloader — EFI with Lanzaboote (Secure Boot)
  boot = {
    # Keep NVIDIA on the newest packaged branch from nixpkgs-unstable.
    kernelPackages = pkgs.unstable.linuxPackages;
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
      theme = "sliced";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "sliced" ];
        })
      ];
    };

    # Silent boot — suppress firmware/kernel noise for a clean splash
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    # Load NVIDIA DRM in initrd so Plymouth runs at native resolution/refresh
    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    kernelParams = [
      "amd_pstate=active"
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      "video=DPMS:off"
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
  # VRR is set to "Never" via home-manager (plasma.nix) so the display
  # never mode-switches between fixed and variable refresh.
  environment.sessionVariables.KWIN_DRM_NO_DIRECT_SCANOUT = "1";

  system.stateVersion = "25.11";
}
