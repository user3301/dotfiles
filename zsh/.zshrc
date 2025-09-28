export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"

ZSH_THEME="mikeh"

plugins=(git z colored-man-pages asdf vi-mode)

source $ZSH/oh-my-zsh.sh

ENVFILE="$HOME/.zshenv"
[[ -s $ENVFILE ]] && source "$ENVFILE"

eval "$(mcfly init zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

