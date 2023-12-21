export ZSH="$XDG_CONFIG_HOME/zsh/oh-my-zsh"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)

source $ZSH/oh-my-zsh.sh

autoload -Uz compinit; compinit

alias cat='bat --paging=never'
