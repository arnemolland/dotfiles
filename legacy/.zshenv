
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

export EDITOR="nvim"
export VISUAL="nvim"

export ZSH="$XDG_CONFIG_HOME/zsh/oh-my-zsh"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

export PATH="$HOME/.local/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:$HOME/.fig/bin:$PATH"
. "$HOME/.cargo/env"
