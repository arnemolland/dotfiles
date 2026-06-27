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
    ../../modules/desktop/openlinkhub.nix
    ../../modules/desktop/github-runner.nix
    # Machine-specific hardware
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  home-manager.backupFileExtension = "bak";

  systemd.tmpfiles.rules = [
    "d /mnt/extendo 0755 root root -"
    "d /mnt/scratch 0755 root root -"
    # Bind target for /run/github-runner — see systemd.mounts below.
    "d /mnt/scratch/github-runner-run 0755 root root -"
  ];

  # Secondary NVMe (ext4) used to offload high-churn root-owned state
  # (github-runner work dirs, podman storage) from the main /nix/store disk.
  fileSystems."/mnt/scratch" = {
    device = "/dev/disk/by-uuid/3c2a5648-8c2f-4175-92ef-0ef6a1f1c468";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  systemd.mounts = [
    {
      what = "/dev/disk/by-uuid/AAC49F80C49F4E07";
      where = "/mnt/extendo";
      type = "ntfs3";
      options = "uid=1000,gid=100,umask=022,force,nofail";
      unitConfig.ConditionPathExists = "/dev/disk/by-uuid/AAC49F80C49F4E07";
    }
    # Move github-runner DynamicUser state off the root disk. The runners'
    # ephemeral work trees thrash /var/lib/private/github-runner — keep it
    # on the secondary NVMe.
    {
      what = "/mnt/scratch/github-runner";
      where = "/var/lib/private/github-runner";
      type = "none";
      options = "bind";
      requires = [ "mnt-scratch.mount" ];
      after = [ "mnt-scratch.mount" ];
      wantedBy = [ "multi-user.target" ];
    }
    # Podman image/layer storage lives here and balloons fast under CI load.
    # Bind the whole containers tree onto scratch so the root disk stays slim.
    {
      what = "/mnt/scratch/containers";
      where = "/var/lib/containers";
      type = "none";
      options = "bind";
      requires = [ "mnt-scratch.mount" ];
      after = [ "mnt-scratch.mount" ];
      before = [
        "podman.service"
        "podman.socket"
      ];
      wantedBy = [ "multi-user.target" ];
    }
    # The GitHub runner module uses RuntimeDirectory=github-runner/<name>,
    # which lands work trees, _temp, _tool and the cloned repo on the /run
    # tmpfs (16 G, RAM-backed). Four concurrent runners cloning monorepos
    # there pushes RAM hard. Bind /run/github-runner onto the scratch SSD
    # so the heavy I/O lands on disk while the runner state files
    # (credentials, .runner) keep their existing scratch bind via
    # /var/lib/private/github-runner above.
    {
      what = "/mnt/scratch/github-runner-run";
      where = "/run/github-runner";
      type = "none";
      options = "bind";
      requires = [ "mnt-scratch.mount" ];
      after = [ "mnt-scratch.mount" ];
      before = [
        "github-runner-frifor-next-1.service"
        "github-runner-frifor-next-2.service"
        "github-runner-frifor-next-3.service"
        "github-runner-frifor-next-4.service"
      ];
      wantedBy = [ "multi-user.target" ];
    }
  ];

  systemd.automounts = [
    {
      where = "/mnt/extendo";
      wantedBy = [ "multi-user.target" ];
      automountConfig.TimeoutIdleSec = "10min";
    }
  ];

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
      # Lanzaboote replaces systemd-boot as the bootloader, but inherits
      # configurationLimit from this option — cap kept generations so /boot
      # and /nix don't accumulate every rebuild forever.
      systemd-boot = {
        enable = lib.mkForce false;
        configurationLimit = 10;
      };
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

  system.stateVersion = "25.11";
}
