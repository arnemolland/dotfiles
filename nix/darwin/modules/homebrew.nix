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
      "logi-options+"
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
      "chatgpt"
      "tableplus"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
