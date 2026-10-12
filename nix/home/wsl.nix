{ pkgs, ... }:

let
  # Claude Code ships several times a week, faster than nixpkgs. Use the
  # official native install (self-updating, in ~/.local/bin; runs via
  # nix-ld). This shim installs it on first use, then hands over.
  claude = pkgs.writeShellApplication {
    name = "claude";
    runtimeInputs = with pkgs; [
      bash
      coreutils
      curl
      gnugrep
      gnused
    ];
    text = ''
      bin="$HOME/.local/bin/claude"
      if [ ! -x "$bin" ]; then
        echo "Installing Claude Code (native, auto-updating)..." >&2
        curl -fsSL https://claude.ai/install.sh | bash
      fi
      exec "$bin" "$@"
    '';
  };
in
{
  imports = [
    ./profiles/cli.nix
    ./modules/openfang.nix
  ];

  home = {
    username = "arne";
    homeDirectory = "/home/arne";

    packages = [ claude ];

    # Keep in sync with HM release version.
    stateVersion = "25.11";
  };
}
