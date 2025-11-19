export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
# This is required for asdf (0.16 or later)
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

ZSH_THEME="mikeh"

plugins=(git z colored-man-pages asdf vi-mode)

source $ZSH/oh-my-zsh.sh

ENVFILE="$HOME/.zshenv"
[[ -s $ENVFILE ]] && source "$ENVFILE"

command -v mcfly &> /dev/null && eval "$(mcfly init zsh)"

#eval "$(zellij setup --generate-auto-start zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

