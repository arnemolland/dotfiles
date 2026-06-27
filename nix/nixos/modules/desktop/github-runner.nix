{
  pkgs,
  config,
  lib,
  ...
}:

let
  runnerCount = 4;

  # Testcontainers' Ryuk sidecar is disabled below (unreliable with Podman),
  # so nothing else reaps the containers/volumes it leaves behind. The
  # runner invokes this script via ACTIONS_RUNNER_HOOK_JOB_COMPLETED after
  # every job to sweep orphans. Images are dangling-pruned only (not -a)
  # to keep the base-image cache warm for subsequent jobs.
  # Name must end in .sh — the GitHub runner validates the hook path's
  # extension and rejects bare store paths.
  jobCompletedHook = pkgs.writeShellScript "gh-runner-job-cleanup.sh" ''
    set -u
    export DOCKER_HOST="unix:///run/docker.sock"
    ${pkgs.docker}/bin/docker container prune -f >/dev/null 2>&1 || true
    ${pkgs.docker}/bin/docker volume prune -f >/dev/null 2>&1 || true
    ${pkgs.docker}/bin/docker image prune -f >/dev/null 2>&1 || true
    exit 0
  '';

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
      podman
      nodejs
      git
      coreutils
      bash
      curl
      jq
    ];

    # Allow the runner to talk to the system podman socket so
    # container-based Actions (docker://) work.
    serviceOverrides = {
      # `services:` in GitHub Actions talks to the Docker API endpoint.
      # With podman docker socket compatibility enabled this endpoint is
      # exposed on /run/docker.sock and controlled by the podman group.
      SupplementaryGroups = [ "podman" ];
    };
    extraEnvironment = {
      # Use the Docker-compatible socket path expected by most actions.
      DOCKER_HOST = "unix:///run/docker.sock";
      # Testcontainers support: Ryuk (cleanup sidecar) is unreliable with
      # Podman — disable it. Cleanup is instead done by jobCompletedHook,
      # wired in via ACTIONS_RUNNER_HOOK_JOB_COMPLETED below.
      TESTCONTAINERS_RYUK_DISABLED = "true";
      # Tell Testcontainers the real socket path for container-internal mounts.
      TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/run/docker.sock";
      # GitHub runner fires this after every job; reaps testcontainers orphans.
      ACTIONS_RUNNER_HOOK_JOB_COMPLETED = "${jobCompletedHook}";
    };

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

  # Safety net: if a job is killed before its completion hook runs,
  # orphans would otherwise accumulate forever. This timer sweeps weekly.
  # Scoped narrower than the per-job hook: image prune is dangling-only
  # to preserve the cache; volumes/containers not attached to a live
  # container are safe to remove even mid-job.
  systemd.services.podman-gc = {
    description = "Periodic podman GC (CI leftovers safety net)";
    serviceConfig.Type = "oneshot";
    path = [ config.virtualisation.podman.package ];
    script = ''
      podman container prune -f || true
      podman volume prune -f || true
      podman image prune -f || true
    '';
  };

  systemd.timers.podman-gc = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
