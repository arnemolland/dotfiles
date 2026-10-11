# Swift on NixOS: run the official toolchain inside an Ubuntu-like FHS
# sandbox (bubblewrap) holding the system libraries swift.org lists as its
# Linux dependencies. Exposes the usual commands plus `swift-env`, a shell
# (or `swift-env <cmd>`) inside the sandbox.
{
  buildFHSEnv,
  runCommand,
  writeShellScript,
  writeShellScriptBin,
  symlinkJoin,
  libedit,
  ncurses,
  swift-toolchain,
}:

let
  # Debian/Ubuntu ship libedit as libedit.so.2; same ABI as upstream's .so.0.
  ubuntuCompat = runCommand "swift-ubuntu-compat" { } ''
    mkdir -p $out/lib
    ln -s ${libedit}/lib/libedit.so.0 $out/lib/libedit.so.2
  '';

  # lldb wants Debian's narrow ncurses with a separate, symbol-versioned
  # libtinfo (NCURSES6_*, NCURSES6_TINFO_*).
  ncursesNarrow = ncurses.override {
    unicodeSupport = false;
    withTermlib = true;
  };

  env = buildFHSEnv {
    name = "swift-env";

    # swift.org/install/linux → Ubuntu 24.04 dependencies, at the sonames
    # that build links against (libxml2.so.2, libpython3.12).
    targetPkgs =
      pkgs: with pkgs; [
        ubuntuCompat
        binutils-unwrapped
        curl
        gcc.cc
        gcc.cc.lib
        git
        glibc
        gnupg
        libedit
        libuuid
        libxml2_13
        ncursesNarrow
        pkg-config
        python312
        sqlite
        tzdata
        unzip
        z3
        zlib
      ];
    extraOutputsToInstall = [ "dev" ];

    runScript = writeShellScript "swift-env-run" ''
      export PATH=${swift-toolchain}/usr/bin:$PATH
      # Several sonames (libncurses.so.6, libtinfo.so.6, libedit.so.2) are
      # symlinks that ld.so.cache indexes under their target's name.
      export LD_LIBRARY_PATH=/usr/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
      if [ $# -eq 0 ]; then exec bash; fi
      exec "$@"
    '';
  };

  # Absolute paths: SwiftPM derives the toolchain location from argv[0].
  wrap =
    cmd: writeShellScriptBin cmd ''exec ${env}/bin/swift-env ${swift-toolchain}/usr/bin/${cmd} "$@"'';
in
symlinkJoin {
  name = "swift-fhs-${swift-toolchain.version}";
  paths = [
    env
  ]
  ++ map wrap [
    "swift"
    "swiftc"
    "sourcekit-lsp"
    "docc"
    "lldb"
  ];
  passthru = { inherit env; };
}
