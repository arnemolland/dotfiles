{ config, pkgs, ... }:

let
  # Upstream OPA tests fail; disable checks for now.
  customOpa = pkgs.open-policy-agent.overrideAttrs (_: {
    doCheck = false;
  });
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
    surrealdb
    flyctl
  ])
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

}
