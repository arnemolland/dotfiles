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
      download-buffer-size = 4294967296;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

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
  ];
}
