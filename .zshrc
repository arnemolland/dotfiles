export ZSH="$XDG_CONFIG_HOME/zsh/oh-my-zsh"

plugins=(git)

source $ZSH/oh-my-zsh.sh

autoload -Uz compinit; compinit