# KDE Plasma settings managed via kwriteconfig6.
# Guarded with mkIf so it's a no-op on non-Linux (arne.nix is shared with darwin).
{ lib, pkgs, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  # VRR "Automatic" — allow Plasma to use adaptive sync for apps that
  # request it. Direct scanout remains disabled in the host config to keep
  # NVIDIA mode switches more predictable, but entering/leaving fullscreen
  # may still reintroduce some flicker on this setup.
  # Values: 0 = Never, 1 = Automatic, 2 = Always
  home.activation.kwinVrrPolicy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
      --file kwinrc --group Compositing --key VrrPolicy 1
  '';

  # Ensure the Breeze splash screen is active so the SDDM-to-desktop
  # transition is covered by a smooth animation instead of a black gap.
  home.activation.ksplash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
      --file ksplashrc --group KSplash --key Engine KSplashQML
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
      --file ksplashrc --group KSplash --key Theme org.kde.breeze.desktop
  '';
}
