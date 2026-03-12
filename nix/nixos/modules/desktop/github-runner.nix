{ pkgs, config, lib, ... }:

let
  runnerCount = 2;

  # Shared configuration for all runner instances
  runnerConfig = id: {
    enable = true;
    url = "https://github.com/frifor/next";
    tokenFile = config.sops.secrets.github-runner-token.path;

    name = "desktop-${toString id}";
    replace = true;

    extraLabels = [
      "nixos"
    ];

    extraPackages = with pkgs; [
      docker
      nodejs
      git
      coreutils
      bash
      curl
      jq
    ];

    ephemeral = true;
  };
in
{
  # Self-hosted GitHub Actions runners for frifor/next.
  #
  # Prerequisites (one-time):
  #   1. Ensure SSH host key is imported by sops-nix (automatic)
  #   2. Add the age public key to .sops.yaml
  #   3. Create & encrypt token:  sops nix/nixos/secrets/github-runner.json
  #   4. The token must be a GitHub PAT (classic) with `repo` scope,
  #      or a fine-grained PAT with "Administration" read/write on the repo.

  sops.secrets.github-runner-token = {
    sopsFile = ../../secrets/github-runner.json;
    format = "json";
    key = "github_runner_token";
  };

  services.github-runners = lib.listToAttrs (
    lib.genList (id: {
      name = "frifor-next-${toString (id + 1)}";
      value = runnerConfig (id + 1);
    }) runnerCount
  );
}
