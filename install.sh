#!/usr/bin/env bash
set -euo pipefail

# This script is intended for GitHub Codespaces dotfiles.
# It installs Nix (if missing) and applies the Home Manager profile `codespaces`.

FLAKE_PATH="${HOME}/.dotfiles"
PROFILE="codespaces"

has_nix() {
  command -v nix >/dev/null 2>&1
}

install_nix() {
  # Determinate Systems installer is non-interactive and works in Codespaces.
  echo "Installing Nix..."
  curl -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
}

activate_profile() {
  echo "Activating Home Manager profile '${PROFILE}' from ${FLAKE_PATH}"
  # Ensure nix command available in current shell
  if [ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
    # shellcheck disable=SC1090
    . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
  fi
  nix run ".#homeConfigurations.${PROFILE}.activationPackage"
}

main() {
  # Codespaces clones dotfiles into ~/.dotfiles by default; adjust if needed.
  cd "${FLAKE_PATH}" 2>/dev/null || cd "${HOME}"

  if ! has_nix; then
    install_nix
    # re-enter shell profile
    . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
  fi

  activate_profile
}

main "$@"
