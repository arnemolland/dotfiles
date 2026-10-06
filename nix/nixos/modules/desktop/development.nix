{ pkgs, ... }:
{
  # Desktop-only development tooling, on top of common/development.nix:
  # GUI apps, Android, and hardware-backed profiling.

  users.users.arne.extraGroups = [
    "kvm"
    "adbusers"
  ];

  environment.systemPackages = with pkgs; [
    sysprof
    dbpro
    opencode-desktop
    android-tools
    android-studio
  ];
}
