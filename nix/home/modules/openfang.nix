{ config, lib, pkgs, ... }:

# OpenFang agent platform — config and data directories.
# Only activated on Linux (the package is Linux-only).

lib.mkIf pkgs.stdenv.isLinux {
  # Seed ~/.openfang/config.toml so `openfang doctor` passes immediately
  # after a NixOS rebuild. The file is mutable (not a symlink) so
  # `openfang init` or manual edits don't fight with home-manager.
  home.activation.openfangInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dir="${config.home.homeDirectory}/.openfang"
    mkdir -p "$dir/data" "$dir/agents"

    if [ ! -f "$dir/config.toml" ]; then
      cat > "$dir/config.toml" << 'EOF'
[default_model]
provider = "ollama"
model = "llama3.1:8b"
# api_key_env = "OPENAI_API_KEY"   # uncomment when switching to a cloud provider

[memory]
decay_rate = 0.05

[network]
listen_addr = "127.0.0.1:4200"
EOF
    fi
  '';
}
