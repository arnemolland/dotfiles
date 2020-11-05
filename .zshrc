export PS1="arne %~ "
export PATH=/usr/local/opt/ruby/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$PATH:$HOME/flutter/bin
export PATH=$PATH:$HOME/.pub-cache/bin
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
export LANG=en_US.UTF-8
export GOPRIVATE="github.com/sendd-app"
export AWS_DEFAULT_PROFILE=arne
export ANDROID_NDK_HOME="/usr/local/share/android-ndk"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export FLUTTER_ROOT="$HOME/flutter"
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$HOME/.linkerd2/bin
export TEAM_ID=2QDU4ARY99
export JAVA_HOME=$HOME/.sdkman/candidates/java/current
export ANDROID_HOME=$ANDROID_SDK_ROOT
export STARSHIP_CONFIG=~/.config/starship.toml
export KUBESAIL_CONFIG=$HOME/.kube/kubesail
export KUBECONFIG=$HOME/.kube/config
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export FASTLANE_APPLE_APP_SPECIFIC_PASSWORD=hqat-bymz-bhfu-rkey

# initial setup
unsetopt PROMPT_SP
neofetch --ascii $HOME/.config/neofetch/ascii-art/dnb.txt
eval "$(starship init zsh)"
# functions
# upload to file.io
fileio() {
    if [ -z "$1" ]; then
        echo "No file passed."
        return
    fi
    if [ -z "$2" ]; then
        echo "No expiry date set. Defaulting to 2 years."
        curl -s -F "file=@$1" "https://file.io/?expires=2y" | jq -r '.link' | pbcopy
        echo "Copied to clipboard"
    else
        curl -s -F "file=@$1" "https://file.io/?expires=$2" | jq -r '.link' | pbcopy
        echo "Copied to clipboard"
    fi
}

# cleans all SVG files in directory
svgclean() {
    for file in *; do
        svgcleaner "$file" "$file"
    done
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion

#Git Proxy
alias gproxy='sudo ssh -f -nNT gitproxy'
alias gproxy-status='sudo ssh -O check gitproxy'
alias gproxy-off='sudo ssh -O exit gitproxy'

export NO_PROXY=127.0.0.1,localhost

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi

source $HOME/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOME/.zsh/completion.zsh

# Load completion config
source $HOME/.zsh/completion.zsh
source $HOME/.aws/aws_zsh_completer.sh

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

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source <(kubectl completion zsh)

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/vault vault
