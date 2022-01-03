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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dnb-asa/tools/master/flutter.sh)"
  ;;
  Linux)
    sudo add-apt-repository ppa:dawidd0811/neofetch
    sudo apt update && sudo apt-get update
    sudo apt-get install apt-transport-https
    sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
    sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
    sudo apt-get install -y dart
    sudo apt install -y $(<apt/packages.txt)
    sudo snap install slack code android-studio kubectl flutter --classic
  ;;
esac

