{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  pname = "opencode";
  version = "1.2.15";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
    hash = "sha256-eLAZRkZOk1ybeSYe2kpI9AZiGweHo1j+YHtscTBfMg4=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    install -m 755 -D opencode $out/bin/opencode
  '';

  meta = with lib; {
    description = "The open source AI coding agent CLI";
    homepage = "https://opencode.ai";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "opencode";
  };
}
