#!/bin/bash

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH="$ZDOTDIR/oh-my-zsh"

create_symlinks() {
    script_dir=$(dirname "$(readlink -f "$0")")

    # z-files, e.g. .zshrc, .zshenv, etc.
    zfiles=$(find . -maxdepth 1 -type f -name "*.z*")
    # non-z dotfles, e.g. .gitconfig, .gitignore, etc. has to start with a dot
    files=$(find . -maxdepth 1 -type f -name ".*" ! -name "*.z*")

    for zfile in $zfiles; do
        name=$(basename $zfile)
        echo "Creating symlink to $name in ${ZDOTDIR}."
        rm -rf ${ZDOTDIR}/$name
        ln -s $script_dir/$name ${ZDOTDIR}/$name
    done

    for file in $files; do
        name=$(basename $file)
        echo "Creating symlink to $name in ${XDG_CONFIG_HOME}."
        rm -rf ${XDG_CONFIG_HOME}/$name
        ln -s $script_dir/$name ${XDG_CONFIG_HOME}/$name
    done

    echo "Creating symlink to .zshenv in /etc/zshenv."
    sudo rm -rf /etc/zshenv
    sudo ln -s ${ZDOTDIR}/.zshenv /etc/zshenv
}

create_symlinks

oh_my_zsh() {
    export ZSH_CUSTOM="$ZSH/custom"
    sh -c "$(curl -sS https://starship.rs/install.sh)" -y -f
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
}

oh_my_zsh

nvchad() {
    if ! command -v nvim &> /dev/null; then
        echo "nvim is not installed; installing."
        case "$OSTYPE" in
            linux*)
                sudo apt install neovim
                ;;
            darwin*)
                /opt/homebrew/bin/brew install neovim
                ;;
            *)
                echo "Unknown OS; exiting."
                exit 1
                ;;
        esac
    fi
    if [ -d ${XDG_CONFIG_HOME}/nvim ]; then
        echo "${XDG_CONFIG_HOME}/nvim already exists; skipping nvchad installation."
        return
    fi
    git clone https://github.com/NvChad/NvChad ${XDG_CONFIG_HOME}/nvim --depth 1
}

nvchad

nerd_fonts() {
    echo "Installing Go-Mono nerd-font."
    curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Go-Mono.zip
    unzip -o Go-Mono.zip -d Go-Mono
    
    # if macOS, font dir is ~/Library/Fonts, else ~/.local/share/fonts
    if [[ "$OSTYPE" == "darwin"* ]]; then
        font_dir="$HOME/Library/Fonts"
    else
        font_dir="$HOME/.local/share/fonts"
    fi

    if [ ! -d "$font_dir" ]; then
        echo "Creating font directory $font_dir."
        mkdir -p "$font_dir"
    fi

    echo "Moving fonts to $font_dir."
    mv Go-Mono/*.ttf "$font_dir"
    rm Go-Mono.zip && rm -rf Go-Mono
}

nerd_fonts

echo ""
echo "====================="
echo "Installation complete"
echo "====================="
echo ""