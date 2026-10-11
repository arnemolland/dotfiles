# Official Swift toolchain (Ubuntu 24.04 build), unmodified. It expects an
# FHS system, so use it through swift-fhs rather than directly.
#
# Source: the toolchain layer of Docker's official swift image, which is the
# swift.org tarball unpacked onto /usr. Pinned by layer digest; to bump, run
# `skopeo inspect docker://swift:<version>-noble` and take the largest layer.
{
  stdenvNoCC,
  callPackage,
}:

let
  fetchOciBlob = callPackage ./fetch-oci-blob.nix { };
in
stdenvNoCC.mkDerivation rec {
  pname = "swift-toolchain";
  version = "6.4.0";

  src = fetchOciBlob {
    name = "swift-${version}-noble-toolchain.tar.gz";
    registry = "registry-1.docker.io";
    repository = "library/swift";
    # swift:6.4.0-noble, linux/amd64
    digest = "sha256:36c236631f64edc7f661f07899515eeaf9e0a8c51979795b675193194f41f75f";
  };

  # Prebuilt binaries: unpack as-is, no patching or stripping. Keep the
  # tarball's <root>/usr layout; Swift Build locates swiftc relative to it.
  buildCommand = ''
    mkdir -p $out
    tar -xzf $src -C $out usr
  '';

  meta = {
    description = "Swift toolchain (official Linux build)";
    homepage = "https://swift.org";
    platforms = [ "x86_64-linux" ];
  };
}
