case `uname` in
  Darwin)
    xcode-select --install || true
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    brew upgrade
    brew tap dart-lang/dart
    brew install $(<homebrew/formulae.txt)
    brew tap homebrew/cask-fonts
    brew install --cask $(<homebrew/casks.txt)
    cp .zshrc ~/.zshrc
    cp -R .config ~/.config
    cp -R .zsh ~/.zsh
    cp -R .aws ~/.aws
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-synyax-highlighting
    git clone https://github.com/zdharma/fast-syntax-highlighting ~/.zsh/fast-syntax-highlighting
  ;;
  Linux)
    add-apt-repository ppa:dawidd0811/neofetch
    apt update && sudo apt-get update
    apt-get install apt-transport-https
    sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
    sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
    curl -fsSL https://starship.rs/install.sh | bash
    apt-get update
    apt-get install dart
    apt install $(<apt/packages.txt)
    snap install slack --classic
    snap install code --classic
    snap install android-studio --classic
    snap install kubectl --classic
  ;;
esac

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dnb-asa/tools/master/flutter.sh)"