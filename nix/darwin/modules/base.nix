{ lib, pkgs, ... }:

{
  security.pam.services.sudo_local.touchIdAuth = true;

  system.startup.chime = false;

  environment.systemPackages = with pkgs; [
    just
    go
    gnugrep
    harfbuzz
    gnumake
    socat
    s3cmd
    tmux
    direnv
    sqlite
    libwebp
    nil
  ];
}
