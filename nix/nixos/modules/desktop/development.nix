{ pkgs, ... }:
{
  # Development toolchain: editors, compilers, languages, CLI utilities,
  # containers, and dynamic linker support for foreign binaries.
  #
  # NOTE: neovim & podman are already added to PATH by their `programs.*` /
  # `virtualisation.*` options — no need to list them in systemPackages.
  # ripgrep, eza, fzf, glib live in home-manager (common.nix).

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      libgcc
    ];
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  users.users.arne.extraGroups = [
    "podman"
    "kvm"
    "adbusers"
  ];

  environment.systemPackages = with pkgs; [
    # Terminal multiplexer
    tmux

    # Profiling / tracing
    strace
    ltrace
    sysprof

    # Compilers & build tools
    gcc
    gnumake
    cmake

    # Languages
    python3
    nodejs
    go

    # Containers (compose helpers — podman itself comes from virtualisation.podman)
    podman-compose
    docker-compose

    # Libraries (commonly needed for native builds)
    libwebp
    vips

    # Dev tools & AI
    dbpro
    opencode-desktop
    opencode
    unstable.ollama
    unstable.ollama-cuda
    android-tools
    android-studio
  ];
}
