{ pkgs, ... }:
{
  # Foundational NixOS settings shared across all desktop/laptop hosts.
  # Covers: nix config, locale, user account, sudo, SSH, networking, swap.
  # NOTE: system.stateVersion belongs in each host, not here.

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      min-free = 5 * 1024 * 1024 * 1024;
      max-free = 20 * 1024 * 1024 * 1024;
      download-buffer-size = 4294967296;
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

  # Cap journald — uncapped logs were a 4 G chunk of the desktop / partition.
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    SystemKeepFree=2G
  '';

  boot.tmp.cleanOnBoot = true;

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
    linger = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
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

  services.tailscale.enable = true;

  networking.networkmanager.enable = true;

  programs.zsh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  environment.systemPackages = with pkgs; [
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
  ];
}
