export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"

ZSH_THEME="sonicradish"

plugins=(git z colored-man-pages asdf)

source $ZSH/oh-my-zsh.sh

ENVFILE="$HOME/.zshenv"
[[ -s $ENVFILE ]] && source "$ENVFILE"

eval "$(zellij setup --generate-auto-start zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

