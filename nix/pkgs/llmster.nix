{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  pname = "llmster";
  version = "0.0.6-1";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://llmster.lmstudio.ai/download/${version}-linux-x64.full.tar.gz";
    hash = "sha256-/EyUu/ZGABoG5QHVUmWzI7gOF6exzRweYcCoEevHGRs=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib # libstdc++, libgomp
  ];

  # Optional runtime deps that may not be present on all systems.
  autoPatchelfIgnoreMissingDeps = [
    "libvulkan.so.1"
    "libcuda.so.1"
    "libcudart.so.11.0"
    "libcublas.so.11"
    "libcublasLt.so.11"
    "libcrypt.so.1"
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/llmster $out/bin
    cp -a llmster .bundle $out/lib/llmster/

    ln -s $out/lib/llmster/llmster $out/bin/llmster

    runHook postInstall
  '';

  meta = {
    description = "LM Studio headless daemon for servers, cloud instances, and CI";
    homepage = "https://lmstudio.ai/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "llmster";
  };
}
