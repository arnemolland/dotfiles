# Used in GitHub Codespaces and other development containers
case $(uname) in
Darwin)
  # commands for OS X go here
  xcode-select --install || true
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  ;;
Linux)
  # commands for Linux go here
  apt-add-repository https://cli.github.com/packages
  sudo apt update
  apt-get update
  sudo apt-get install -y \
    curl \
    gh \
    git \
    gnupg2 \
    jq \
    sudo \
    zsh \
    unzip
  yes | curl -fsSL https://starship.rs/install.sh | bash
  echo 'eval "(starship init zsh)"' >>$HOME/.zshrc
  ./fonts.sh
  ;;
esac
