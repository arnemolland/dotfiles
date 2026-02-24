{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "dbpro";
  version = "1.7.1";
  src = fetchurl {
    url = "https://releases.dbpro.app/linux-x64/DB%20Pro-${version}-x86_64.AppImage";
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
          tmpDesktop=$(mktemp)
          cp "$desktopFile" "$tmpDesktop"
          sed -i "s|^Exec=.*|Exec=${pname} %U|" "$tmpDesktop"
          if ! grep -q '^TryExec=' "$tmpDesktop"; then
            printf '%s\n' "TryExec=${pname}" >> "$tmpDesktop"
          fi
          install -m 444 -D "$tmpDesktop" $out/share/applications/${pname}.desktop
        fi

        pngIcon=$(find ${appimage} -maxdepth 1 -name "*.png" -print | sort | tail -n1)
        if [ -n "$pngIcon" ]; then
          install -m 444 -D "$pngIcon" $out/share/icons/hicolor/256x256/apps/${pname}.png
        fi

        svgIcon=$(find ${appimage} -maxdepth 1 -name "*.svg" -print -quit)
        if [ -n "$svgIcon" ]; then
          install -m 444 -D "$svgIcon" $out/share/icons/hicolor/scalable/apps/${pname}.svg
        fi

        mkdir -p $out/share/kservices6
        cat > $out/share/kservices6/${pname}.protocol <<'PROTO'
    [Protocol]
    protocol=dbpro
    exec=dbpro %u
    input=none
    output=none
    helper=true
    listing=false
    reading=false
    writing=false
    makedir=false
    deleting=false
    Icon=dbpro
    PROTO
  '';

  meta = with lib; {
    description = "DB Pro";
    homepage = "https://www.dbpro.app";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
