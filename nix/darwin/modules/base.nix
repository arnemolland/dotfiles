{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "arne" ];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.startup.chime = false;

  environment.systemPackages = with pkgs; [
    just
    go
    gnugrep
    harfbuzz
    gnumake
    maestro
    socat
    s3cmd
    tmux
    direnv
    sqlite
    libwebp
    nil
  ];
}
