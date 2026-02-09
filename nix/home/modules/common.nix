{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # Upstream OPA tests fail; disable checks for now.
  customOpa = pkgs.open-policy-agent.overrideAttrs (_: {
    doCheck = false;
  });
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
in
{
  xdg.enable = true;

  home.sessionVariables = {
    BUN_INSTALL = "${config.home.homeDirectory}/.bun";
    FZF_BASE = "${pkgs.fzf}/share/fzf";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.fig/bin"
    "/opt/homebrew/opt/coreutils/libexec/gnubin"
    "${config.home.homeDirectory}/.bun/bin"
    "${config.home.homeDirectory}/.nix-profile/bin"
    "/run/current-system/sw/bin"
  ];

  home.packages = [
    customOpa
    pkgs.nixd
    pkgs.nil
    pkgs.flyctl
  ]
  ++ (with pkgs; [
    bat
    eza
    coreutils
    fzf
    ripgrep
    fd
    gopls
    dart
    rust-analyzer
    zls
    sqls
    dockerfile-language-server-nodejs
    lua-language-server
    nodePackages.typescript-language-server
    pyright
    flyctl
    pkgsUnstable.bun
  ])
  ++ lib.optionals pkgs.stdenv.isLinux (
    with pkgs;
    [
      # Puppeteer/Chromium runtime deps for Linux (chrome-headless-shell).
      glib
      nss
      nspr
      atk
      at-spi2-atk
      cups
      libdrm
      libxkbcommon
      libxshmfence
      mesa
      pango
      cairo
      gdk-pixbuf
      gtk3
      alsa-lib
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXrender
      xorg.libXcursor
      xorg.libXi
      xorg.libXScrnSaver
      xorg.libXtst
      xorg.libxcb
    ]
  )
  ++ [
    (pkgs.writeShellScriptBin "ai-chat" ''
      set -euo pipefail

      available=()
      for bin in codex claude gemini gemini-cli; do
        if command -v "$bin" >/dev/null 2>&1; then
          available+=("$bin")
        fi
      done

      if [ ''${#available[@]} -eq 0 ]; then
        printf '%s\n' "No AI CLI found (codex, claude, gemini-cli). Install one and retry."
        exit 1
      fi

      selection=""
      if [ ''${#available[@]} -eq 1 ]; then
        selection=''${available[0]}
      elif command -v fzf >/dev/null 2>&1; then
        selection=$(printf '%s\n' "''${available[@]}" | fzf --prompt='AI: ' --height=40% --reverse) || exit 0
      else
        selection=''${available[0]}
      fi

      case "$selection" in
        codex) exec codex chat ;;
        claude) exec claude chat ;;
        gemini|gemini-cli) exec gemini-cli chat ;;
        *)
          printf 'Unsupported selection: %s\n' "$selection"
          exit 1
          ;;
      esac
    '')
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gh = {
    enable = true;
    # Default to SSH for repo interactions; matches typical Git setups.
    settings.git_protocol = "ssh";
  };

  # Optional Berkeley Mono on macOS: place .otf files at
  # ~/.local/share/fonts/berkeley-mono/ (keep out of git if you sync). This lets
  # fontconfig/Ghostty use them directly.
  home.file =
    let
      fm = "${config.home.homeDirectory}/.local/share/fonts/berkeley-mono";
      mk = name: {
        name = ".local/share/fonts/berkeley-mono/${name}";
        value.source = config.lib.file.mkOutOfStoreSymlink "${fm}/${name}";
      };
    in
    builtins.listToAttrs (
      map mk [
        "BerkeleyMono-Thin.otf"
        "BerkeleyMono-Thin-Oblique.otf"
        "BerkeleyMono-ExtraLight.otf"
        "BerkeleyMono-ExtraLight-Oblique.otf"
        "BerkeleyMono-Light.otf"
        "BerkeleyMono-Light-Oblique.otf"
        "BerkeleyMono-SemiLight.otf"
        "BerkeleyMono-SemiLight-Oblique.otf"
        "BerkeleyMono-Regular.otf"
        "BerkeleyMono-Oblique.otf"
        "BerkeleyMono-Medium.otf"
        "BerkeleyMono-Medium-Oblique.otf"
        "BerkeleyMono-SemiBold.otf"
        "BerkeleyMono-SemiBold-Oblique.otf"
        "BerkeleyMono-Bold.otf"
        "BerkeleyMono-Bold-Oblique.otf"
        "BerkeleyMono-ExtraBold.otf"
        "BerkeleyMono-ExtraBold-Oblique.otf"
        "BerkeleyMono-Black.otf"
        "BerkeleyMono-Black-Oblique.otf"
      ]
    );
}
