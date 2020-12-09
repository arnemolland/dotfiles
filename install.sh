# Used in GitHub Codespaces and other development containers
case $(uname) in
Darwin)
  # commands for OS X go here
  xcode-select --install || true
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  ;;
Linux)
  # commands for Linux go here
  sudo apt update
  yes | curl -fsSL https://starship.rs/install.sh | bash
  ;;
esac
