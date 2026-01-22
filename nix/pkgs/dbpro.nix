{ lib
, fetchurl
, appimageTools
}:

let
  pname = "dbpro";
  version = "1.4.1";
  src = fetchurl {
    url = "https://releases.dbpro.app/linux-x64/DB%20Pro-1.4.1-x86_64.AppImage";
    sha256 = "1mck3ncm43k119qwwib7haar3simwmkwkg3dvbfyqrnm883l0acp";
    name = "dbpro-${version}.AppImage";
  };
  appimage = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    desktopFile=$(find ${appimage} -maxdepth 1 -name "*.desktop" -print -quit)
    if [ -n "$desktopFile" ]; then
      install -m 444 -D "$desktopFile" $out/share/applications/${pname}.desktop
      sed -i "s|^Exec=.*|Exec=${pname}|" $out/share/applications/${pname}.desktop
    fi

    pngIcon=$(find ${appimage} -maxdepth 1 -name "*.png" -print | sort | tail -n1)
    if [ -n "$pngIcon" ]; then
      install -m 444 -D "$pngIcon" $out/share/icons/hicolor/256x256/apps/${pname}.png
    fi

    svgIcon=$(find ${appimage} -maxdepth 1 -name "*.svg" -print -quit)
    if [ -n "$svgIcon" ]; then
      install -m 444 -D "$svgIcon" $out/share/icons/hicolor/scalable/apps/${pname}.svg
    fi
  '';

  meta = with lib; {
    description = "DB Pro";
    homepage = "https://www.dbpro.app";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
