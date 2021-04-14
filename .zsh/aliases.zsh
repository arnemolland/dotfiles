# aliases
alias sim="open -a simulator"                                                                                                     # shortcut to iOS simulator
alias typora="open -a typora"                                                                                                     # shortcut to Typora
alias bruh="brew"                                                                                                                 # bruh
alias please="sudo !!"                                                                                                            # retry with sudo
alias yeet="rm -rf"                                                                                                               # self explanatory
alias androidfp="keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android" # get android debug fingerprint
alias generate="flutter packages pub run build_runner watch --delete-conflicting-outputs"                                         # source generation in flutter
alias fwoff="sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 0"
alias fwon="sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1"
alias ls='ls -G'                  # colorize `ls` output
alias zshreload='source ~/.zshrc' # reload ZSH
alias shtop='sudo htop'           # run `htop` with root rights
alias grep='grep --color=auto'    # colorize `grep` output
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias less='less -R'
alias g='git'
alias k='kubectl'
alias mk='minikube'
alias cat='bat'
alias tf='terraform'
alias dc='docker-compose'
alias mail='himalaya'
alias rm='rm -i'                  # confirm removal
alias cp='cp -i'                  # confirm copy
alias mv='mv -i'                  # confirm move
alias cal='gcal --starting-day=1' # print simple calendar for current month
alias weather='curl v2.wttr.in'   # print weather for current location (https://github.com/chubin/wttr.in)