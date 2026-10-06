{ pkgs, ... }:
{
  # Bare-metal settings for desktop/laptop hosts, on top of common/base.nix.
  # Covers: console, swap, hardware groups, sudo, SSH, networking.

  boot.tmp.cleanOnBoot = true;

  console = {
    keyMap = "no";
  };

  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "no";
  };

  zramSwap.enable = true;

  users.users.arne = {
    linger = true;
    extraGroups = [
      "networkmanager"
      "audio"
      "video"
      "input"
    ];
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

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
  ];
}
