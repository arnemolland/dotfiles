{ pkgs, ... }:
{
  # Foundation shared by every NixOS host (desktop, WSL, ...).
  # Covers: nix config, locale, user account, shell, core CLI tools.
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

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.arne = {
    isNormalUser = true;
    description = "Arne";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  # Pinentry is host-specific (GUI on desktop, curses elsewhere).
  programs.gnupg.agent.enable = true;

  environment.systemPackages = with pkgs; [
    git
    gnupg
    curl
    wget
    unzip
    zip
    ncdu
    htop
    btop
    # Lets `ssh` sessions from Ghostty (TERM=xterm-ghostty) render properly.
    ghostty.terminfo
  ];
}
