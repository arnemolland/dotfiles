# OpenChamber Web - browser-based GUI for the OpenCode AI coding agent.
# Runs a local web server as a systemd user service on Linux.
{ lib, pkgs, ... }:
let
  port = 3210;
in
lib.mkIf pkgs.stdenv.isLinux {
  home.packages = [
    pkgs.openchamber-web
  ];

  # Run the OpenChamber web server as a background service.
  systemd.user.services.openchamber-web = {
    Unit = {
      Description = "OpenChamber Web - GUI for OpenCode AI agent";
      Documentation = "https://github.com/btriapitsyn/openchamber";
      After = [ "default.target" ];
      PartOf = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.openchamber-web} serve --foreground --host 0.0.0.0 --port ${toString port}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
