{ pkgs, ... }:

let
  pkg = pkgs.unstable.openlinkhub;
  src = pkg.src;
in
{
  # OpenLinkHub — Linux replacement for Corsair iCUE.
  # Primary motivation here: SCUF Envision Pro V2 controller (paddles,
  # G-keys, triggers, vibration) via the virtual-gamepad bridge.
  #
  # The nixpkgs package ships only the binary; the daemon does os.Getwd()
  # and expects database/, static/, web/, openrgb/ alongside it. We
  # assemble those under /var/lib/openlinkhub on service start. Web UI:
  # http://127.0.0.1:27003/

  users.groups.openlinkhub = { };
  users.users.openlinkhub = {
    isSystemUser = true;
    group = "openlinkhub";
    extraGroups = [ "input" ];
    home = "/var/lib/openlinkhub";
  };

  services.udev.extraRules = builtins.readFile "${src}/99-openlinkhub.rules";

  systemd.services.openlinkhub = {
    description = "OpenLinkHub — Corsair / SCUF device daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "sleep.target" ];

    serviceConfig = {
      Type = "simple";
      User = "openlinkhub";
      Group = "openlinkhub";
      StateDirectory = "openlinkhub";
      StateDirectoryMode = "0750";
      WorkingDirectory = "/var/lib/openlinkhub";
      ExecStart = "${pkg}/bin/OpenLinkHub";
      Restart = "on-failure";
      RestartSec = 5;
    };

    preStart = ''
      ln -sfn ${src}/static  static
      ln -sfn ${src}/web     web
      ln -sfn ${src}/openrgb openrgb

      # database/ holds user-editable JSON (rgb profiles, key mappings).
      # Seed it from the source on first run; never overwrite afterwards.
      if [ ! -d database ]; then
        cp -r --no-preserve=mode,ownership ${src}/database database
      fi
    '';
  };
}
