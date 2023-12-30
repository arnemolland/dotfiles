# Fig pre block. Keep at the top of this file.
# [[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

export ZSH="$XDG_CONFIG_HOME/zsh/oh-my-zsh"

plugins=(git zsh-syntax-highlighting fast-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
source $ZDOTDIR/.aliases.zsh

eval "$(/opt/homebrew/bin/brew shellenv)"
eval `gdircolors $XDG_CONFIG_HOME/.dircolors`
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

autoload -Uz compinit; compinit

# Fig post block. Keep at the bottom of this file.
# [[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
