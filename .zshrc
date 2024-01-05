# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

export ZSH="$XDG_CONFIG_HOME/zsh/oh-my-zsh"
export NVM_DIR="$XDG_DATA_HOME"/nvm
export SPACEVIM_RUNTIMEPATH="$XDG_CONFIG_HOME/zsh/spaceship.zsh"
export RPS1="%{$reset_color%}"
export ZSH_THEME="spaceship"

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

plugins=(git
         zsh-syntax-highlighting 
         fast-syntax-highlighting 
         zsh-completions 
         zsh-autosuggestions 
         spaceship-vi-mode 
         aws 
         fzf
         terraform
         ssh-agent
         kubectl 
         vimond-zsh-plugin
         autoupdate
        )

source $ZSH/oh-my-zsh.sh

eval "$(/opt/homebrew/bin/brew shellenv)"
eval `gdircolors $XDG_CONFIG_HOME/.dircolors`
eval "$(direnv hook zsh)"

autoload -Uz compinit; compinit

source $ZDOTDIR/.aliases.zsh

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
