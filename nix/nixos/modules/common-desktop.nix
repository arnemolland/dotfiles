{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # Base NixOS desktop defaults shared by hosts.

  system.stateVersion = "25.11";
  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-36.9.5"
      ];
    };
    overlays = [
      (import ../../overlays)
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.download-buffer-size = 4294967296;

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "no";
  };

  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "no";
  };

  zramSwap.enable = true;

  users.users.arne = {
    isNormalUser = true;
    description = "Arne";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "podman"
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
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };

  services.tailscale.enable = true;

  programs.zsh.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      libgcc
    ];
  };
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  networking.networkmanager.enable = true;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

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
      pkgs.xdg-desktop-portal-hyprland
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

  environment.systemPackages = with pkgs; [
    git
    gnupg
    curl
    wget
    unzip
    zip
    pciutils
    usbutils
    neovim
    tmux
    ripgrep
    eza
    fzf
    gcc
    gnumake
    cmake
    python3
    nodejs
    go
    ghostty
    zed-editor
    mangohud
    vkbasalt
    nvtopPackages.full
    strace
    ltrace
    sysprof
    podman
    podman-compose
    podman-desktop
    docker-compose
    libwebp
    spotify
    discord
    slack
  ];
}
