export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="sonicradish"

plugins=(git z colored-man-pages tmux)

ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh
source ~/.zshenv
source ~/.config/envman/load.sh

. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

. ~/.asdf/plugins/golang/set-env.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/gaiz/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/gaiz/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/gaiz/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/gaiz/google-cloud-sdk/completion.zsh.inc'; fi

eval "$(mcfly init zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

