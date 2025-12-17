{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "neovim"
      "node"
      "bun"
      "postgresql"
      "valkey"
      "meilisearch"
      "nats-server"
      "gh"
      "gnupg"
      "lazygit"
      "opa"
      "tree"
      "swift-format"
      "spaceship"
      "starship"
      "supabase"
      "doctl"
    ];

    casks = [
      "google-chrome"
      "figma"
      "ghostty"
      "google-drive"
      "minecraft"
      "ollama-app"
      "orbstack"
      "raycast"
      "slack"
      "steam"
      "tailscale-app"
      "typora"
      "vagrant"
      "zed"
      "vlc"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
