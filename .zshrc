export PATH=$PATH:$HOME/flutter/bin
export PATH=$PATH:/opt/homebrew/bin
export PS1="arne %~ "
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$PATH:$HOME/flutter/bin
export PATH=$PATH:$HOME/.pub-cache/bin
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
export LANG=en_US.UTF-8
export AWS_DEFAULT_PROFILE=arne
export ANDROID_NDK_HOME=/usr/local/share/android-ndk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export FLUTTER_ROOT="$HOME/flutter"
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$HOME/.linkerd2/bin
export JAVA_HOME=$HOME/.sdkman/candidates/java/current
export ANDROID_HOME=$ANDROID_SDK_ROOT
export STARSHIP_CONFIG=~/.config/starship.toml
export KUBESAIL_CONFIG=$HOME/.kube/kubesail
export KUBECONFIG=$HOME/.kube/config
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.dotnet/tools
export EDITOR=$(which vim)

# initial setup
unsetopt PROMPT_SP
eval "$(starship init zsh)"
eval "$(goenv init -)"
eval "$(direnv hook zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export NO_PROXY=127.0.0.1,localhost

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi

source $HOME/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOME/.zsh/completion.zsh

# Load completion config
source $HOME/.zsh/completion.zsh

# Initialize the completion system
autoload -Uz compinit

# Cache completion if nothing changed - faster startup time
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
    compinit -i
else
    compinit -C -i
fi

# Enhanced form of menu completion called `menu selection'
zmodload -i zsh/complist
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/history.zsh
alias ls='ls -G'
source $HOME/.zsh/key-bindings.zsh
source $HOME/.zsh/aliases.zsh
source $HOME/.zsh/functions.zsh

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source <(kubectl completion zsh)

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/vault vault

# Google Cloud SDK
source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc

complete -o nospace -C /usr/local/bin/terraform terraform

export PATH=$PATH:/Users/arnemolland/flutter/bin
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH=$PATH:/Users/arnemolland/flutter/bin
