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
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.openchamber-web} --port ${toString port}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
