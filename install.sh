#!/bin/bash

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export ZSH="$XDG_CONFIG_HOME/zsh/oh-my-zsh"

create_symlinks() {
    script_dir=$(dirname "$(readlink -f "$0")")

    files=$(find . -maxdepth 1 -type f -name ".*")

    for file in $files; do
        name=$(basename $file)
        echo "Creating symlink to $name in ${XDG_CONFIG_HOME}."
        rm -rf ${XDG_CONFIG_HOME}/$name
        ln -s $script_dir/$name ${XDG_CONFIG_HOME}/$name
    done
}

create_symlinks

oh_my_zsh() {
    sh -c "$(curl -sS https://starship.rs/install.sh)" -y -f
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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