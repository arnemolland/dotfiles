{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.enable = true;

  home = {
    sessionVariables = {
      BUN_INSTALL = "${config.home.homeDirectory}/.bun";
      FZF_BASE = "${pkgs.fzf}/share/fzf";
    };

    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      "${config.home.homeDirectory}/.fig/bin"
      "/opt/homebrew/opt/coreutils/libexec/gnubin"
      "${config.home.homeDirectory}/.bun/bin"
      "${config.home.homeDirectory}/.nix-profile/bin"
      "/run/current-system/sw/bin"
    ];

    packages = [
      pkgs.open-policy-agent
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
      dockerfile-language-server
      lua-language-server
      nodePackages.typescript-language-server
      pyright
      unstable.bun
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

  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gh = {
    enable = true;
    # Default to SSH for repo interactions; matches typical Git setups.
    settings.git_protocol = "ssh";
  };
}
