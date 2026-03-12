# KDE Plasma settings managed via kwriteconfig6.
# Guarded with mkIf so it's a no-op on non-Linux (arne.nix is shared with darwin).
{ lib, pkgs, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  # VRR "Always" — keep the display in variable-refresh mode permanently so
  # toggling fullscreen never triggers a VRR ↔ fixed-refresh mode switch.
  # KDE default is "Automatic" (VRR only for fullscreen), which causes a
  # black-screen flash on every fullscreen transition with NVIDIA.
  # Values: 0 = Never, 1 = Automatic, 2 = Always
  home.activation.kwinVrrAlways = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
      --file kwinrc --group Compositing --key VrrPolicy 2
  '';
}
