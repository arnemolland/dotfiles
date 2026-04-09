{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "lmstudio";
  version = "0.4.10-1";

  src = fetchurl {
    url = "https://installers.lmstudio.ai/linux/x64/${version}/LM-Studio-${version}-x64.AppImage";
    hash = "sha256-FC7rPA1CxTaYakpSSpjxYiPETW8+N5QmsmUib3RHD0o=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.ocl-icd ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons/hicolor/512x512/apps
    install -m 444 ${appimageContents}/lm-studio.desktop $out/share/applications/lm-studio.desktop
    install -m 444 ${appimageContents}/resources/app/.webpack/Icon-512x512.png $out/share/icons/hicolor/512x512/apps/lm-studio.png

    # Rename the main executable from lmstudio to lm-studio
    mv $out/bin/lmstudio $out/bin/lm-studio

    substituteInPlace $out/share/applications/lm-studio.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=lm-studio'
  '';

  meta = {
    description = "Desktop app for experimenting with local and open-source LLMs";
    homepage = "https://lmstudio.ai/";
    license = lib.licenses.unfree;
    mainProgram = "lm-studio";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
