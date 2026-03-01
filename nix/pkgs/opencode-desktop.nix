{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  gtk3,
  glib,
  nss,
  nspr,
  atk,
  cups,
  dbus,
  libdrm,
  expat,
  libxcb,
  libxkbcommon,
  xorg,
  mesa,
  udev,
  alsa-lib,
  webkitgtk_4_1,
  libsoup_3,
}:

let
  pname = "opencode-desktop";
  version = "1.2.15";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-desktop-linux-amd64.deb";
    sha256 = "1w8wlz4qyfafiqw3p4adwnvl38i4r4ddpimj7gvpddjlwr7qb6ac";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    gtk3
    glib
    nss
    nspr
    atk
    cups
    dbus
    libdrm
    expat
    libxcb
    libxkbcommon
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxshmfence
    mesa
    udev
    alsa-lib
    webkitgtk_4_1
    libsoup_3
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share

    cp -r usr/share/. $out/share/

    # Binaries ship directly in usr/bin
    install -m 755 usr/bin/OpenCode $out/bin/.OpenCode-wrapped-real
    makeWrapper $out/bin/.OpenCode-wrapped-real $out/bin/opencode-desktop \
      --add-flags "--no-sandbox"

    # Two code paths in the app both need to find opencode-cli:
    #
    # 1. Tauri native sidecar mechanism: looks for
    #    <exe_dir>/sidecars/opencode-cli-x86_64-unknown-linux-gnu
    #    (Tauri appends the target triple)
    #
    # 2. opencode_lib::cli shell path: invokes `zsh -l -c <exe_dir>/opencode-cli`
    #    (plain name, no sidecars/ subdirectory)
    #
    # Both paths are relative to the real executable ($out/bin/.OpenCode-wrapped-real).
    mkdir -p $out/bin/sidecars
    install -m 755 usr/bin/opencode-cli \
      $out/bin/sidecars/opencode-cli-x86_64-unknown-linux-gnu
    # Plain sibling for the shell-based launch path
    install -m 755 usr/bin/opencode-cli $out/bin/opencode-cli

    # Fix the .desktop Exec entry to use our wrapper
    substituteInPlace $out/share/applications/OpenCode.desktop \
      --replace-fail "Exec=OpenCode" "Exec=opencode-desktop"
  '';

  meta = with lib; {
    description = "The open source AI coding agent desktop app";
    homepage = "https://opencode.ai";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "opencode-desktop";
  };
}
