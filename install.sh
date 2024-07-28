#!/bin/bash

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH="$ZDOTDIR/oh-my-zsh"

homebrew() {
	if ! command -v brew &>/dev/null; then
		echo "Homebrew is not installed; installing."
		case "$OSTYPE" in
		linux*)
			case $(lsb_release -is) in
			Ubuntu)
				sudo apt update
				sudo apt install build-essential curl file git
				/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
				;;
			# alpine
			Alpine*)
				sudo apk update --no-cache
				sudo apk add build-base curl file git
				/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
				;;
			*)
				echo "Unknown Linux distribution; exiting."
				exit 1
				;;
			esac
		darwin*)
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			;;
		*)
			echo "Unknown OS; exiting."
			exit 1
			;;
		esac
	fi
}

create_symlinks() {
	script_dir=$(dirname "$(readlink -f "$0")")
	# z-files, e.g. .zshrc, .zshenv, etc.
	zfiles=$(find . -maxdepth 1 -type f -name "*.z*")
	# non-z dotfles, e.g. .gitconfig, .gitignore, etc. has to start with a dot
	files=$(find . -maxdepth 1 -type f -name ".*" ! -name "*.z*")
	# config directories, e.g. alacritty, nvim, git, etc. but excluding .* directories
	cfgdirs=$(find . -maxdepth 1 -type d -name "*" ! -name ".*")

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

	for cfgdir in $cfgdirs; do
		name=$(basename $cfgdir)
		echo "Creating symlink to $name in ${XDG_CONFIG_HOME}."
		rm -rf ${XDG_CONFIG_HOME}/$name
		ln -s $script_dir/$name ${XDG_CONFIG_HOME}/$name
	done
}

oh_my_zsh() {
	export ZSH_CUSTOM="$ZSH/custom"
	sh -c "$(curl -sS https://starship.rs/install.sh)" -y -f
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
	git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting
	git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
}

kickstart_nvim() {
	if ! command -v nvim &>/dev/null; then
		echo "nvim is not installed; installing."
		case "$OSTYPE" in
		linux*)
			case $(lsb_release -is) in
			Ubuntu)
				sudo apt update
				sudo apt install neovim
				;;
			# alpine
			Alpine*)
				sudo apk add neovim
				;;
			*)
				echo "Unknown Linux distribution; exiting."
				exit 1
				;;
			esac
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
		echo "${XDG_CONFIG_HOME}/nvim already exists; skipping kickstart installation."
		return
	fi
	git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim --depth 1
}

system_setup() {
	case "$OSTYPE" in
	darwin*)
		echo "Setting up macOS defaults."
		# Disable the sound effects on boot
		sudo nvram SystemAudioVolume=" "
		# Disable the sound effects when changing the volume
		defaults write -g com.apple.sound.beep.feedback -integer 0
		# Disable the warning when changing a file extension
		defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
		# Enable Touch ID for sudo
		sudo sed -i '' '2i\
        auth       sufficient     pam_tid.so\
        ' /etc/pam.d/sudo
		;;
	*)
		echo "Not macOS; exiting."
		exit 1
		;;
	esac
}

software_install() {
    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    # Install Bun
    curl -fsSL https://bun.sh/install | bash
}

postinstall() {
    # Append git/postinstall content to ./git/config
    cat $(pwd)/git/postinstall >> $(pwd)/git/config
}

homebrew
create_symlinks
oh_my_zsh
kickstart_nvim
system_setup
software_install
postinstall

echo ""
echo "============================="
echo "Installation complete"
echo "============================="
echo "Reminders:"
echo " 1. Restart your shell"
echo " 2. Download and patch fonts"
echo "============================="
echo " "
