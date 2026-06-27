{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

# Sellable / handover baseline for the desktop hardware.
#
# Same machine as hosts/desktop, but with every personal identity stripped:
#   - no `arne` user (generic `nixos` login instead)
#   - no tailscale, no sops secrets, no github-runner
#   - no private Berkeley Mono font, no scratch/extendo bind mounts
#   - no home-manager
#
# Secure Boot (lanzaboote) is kept as a baseline feature, but the PKI in
# /var/lib/sbctl is NOT transferred — the new owner generates and enrols
# their own keys after install (see the handover runbook).

{
  imports = [
    ../../modules/desktop/environment.nix
    ../../modules/desktop/apps.nix
    ../../modules/desktop/gaming.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";

  # ---- Nix ----
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
  };

  boot.tmp.cleanOnBoot = true;

  # ---- Locale / input ----
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "no";
  environment.sessionVariables.XKB_DEFAULT_LAYOUT = "no";

  zramSwap.enable = true;

  # ---- Generic handover user ----
  # initialPassword is set only on first activation; the new owner should
  # change it (passwd) and/or recreate the account immediately.
  users.users.nixos = {
    isNormalUser = true;
    description = "NixOS";
    initialPassword = "nixos";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "podman"
      "kvm"
      "adbusers"
    ];
    shell = pkgs.zsh;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };

  networking.networkmanager.enable = true;
  programs.zsh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # ---- Dev toolchain (generic; personal/overlay apps dropped) ----
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      libgcc

      # Browser runtime deps (Playwright / Chromium / Electron)
      glib
      nspr
      nss
      gtk3
      pango
      cairo
      atk
      dbus
      expat
      libdrm
      mesa
      libgbm
      libglvnd
      libxkbcommon
      cups
      at-spi2-core
      at-spi2-atk
      pkgs."alsa-lib"
      xorg.libxshmfence
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXtst
    ];
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # ---- KDE Plasma (Wayland) with stock SDDM ----
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings = {
        Wayland.EnableHiDPI = true;
        X11.EnableHiDPI = true;
      };
    };
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = true;
  };

  # ---- Boot / Secure Boot (lanzaboote) ----
  boot = {
    kernelPackages = pkgs.unstable.linuxPackages;
    loader = {
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
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.enable = true;
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
      "quiet"
    ];
  };

  environment.systemPackages = with pkgs; [
    # base utilities
    git
    gnupg
    curl
    wget
    unzip
    zip
    pciutils
    usbutils
    ncdu
    htop
    btop
    # Secure Boot tooling (new owner enrols their own keys)
    sbctl
    # generic dev toolchain
    tmux
    gcc
    gnumake
    cmake
    python3
    nodejs
    go
    podman-compose
    docker-compose
  ];

  # ---- Hardware (RTX 4080 / AMD) ----
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

  system.stateVersion = "25.11";
}
