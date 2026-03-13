# KDE Plasma settings managed via kwriteconfig6.
# Guarded with mkIf so it's a no-op on non-Linux (arne.nix is shared with darwin).
{ lib, pkgs, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  # VRR "Never" — disable KWin's VRR entirely to avoid mode switches.
  # Direct scanout is already disabled via KWIN_DRM_NO_DIRECT_SCANOUT=1
  # (desktop/default.nix) so the compositor never yields to fullscreen apps.
  # With both settings, entering/leaving fullscreen causes zero display
  # mode renegotiation — no flicker, no signal loss.
  # Games that need VRR can use Gamescope as a nested compositor.
  # Values: 0 = Never, 1 = Automatic, 2 = Always
  home.activation.kwinVrrPolicy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
      --file kwinrc --group Compositing --key VrrPolicy 0
  '';
}
