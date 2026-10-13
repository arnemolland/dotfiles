# xtool: cross-platform Xcode replacement (https://xtool.sh). Runs inside the
# swift-fhs sandbox, since it drives the Swift toolchain for builds.
#
# Source: the layer of the official ghcr.io/xtool-org/xtool image that holds
# the extracted release AppImage (/usr/local/xtool). Pinned by layer digest;
# to bump, `skopeo inspect --raw` the new tag's linux/amd64 manifest and take
# the last layer.
{
  stdenvNoCC,
  callPackage,
  writeShellScriptBin,
  swift-fhs,
}:

let
  fetchOciBlob = callPackage ./fetch-oci-blob.nix { };

  appdir = stdenvNoCC.mkDerivation rec {
    pname = "xtool-appdir";
    version = "1.21.0";

    src = fetchOciBlob {
      name = "xtool-${version}-appdir.tar.gz";
      registry = "ghcr.io";
      repository = "xtool-org/xtool";
      # xtool:1.21.0, linux/amd64, layer 7/7
      digest = "sha256:354bf366b531c0cdbe79487a6c06757ae39a0ae6a31a2f6e5c194eb7a6e5c69c";
    };

    buildCommand = ''
      mkdir -p $out
      tar -xzf $src -C $out --strip-components=3 usr/local/xtool
      test -e $out/AppRun

      # Drop the bundled OpenSSL 3.0: it shadows the env's newer one, which
      # the env's libcurl needs (OPENSSL_3.5.0). 3.x is backward compatible.
      rm -f $out/usr/lib/libssl.so* $out/usr/lib/libcrypto.so*
    '';
  };
in
(writeShellScriptBin "xtool" ''
  export APPDIR=${appdir}
  exec ${swift-fhs.env}/bin/swift-env ${appdir}/AppRun "$@"
'').overrideAttrs
  {
    inherit (appdir) version;
    meta = {
      description = "Cross-platform Xcode replacement";
      homepage = "https://xtool.sh";
      mainProgram = "xtool";
      platforms = [ "x86_64-linux" ];
    };
  }
