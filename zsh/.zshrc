export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="sonicradish"

plugins=(git z colored-man-pages tmux asdf)

if [ "$TERM_PROGRAM" = 'ghostty' ] || [ "$TERM_PROGRAM" = 'WezTerm' ]
then
   ZSH_TMUX_AUTOSTART=true
fi

source $ZSH/oh-my-zsh.sh

ENVFILE="$HOME/.zshenv"
[[ -s $ENVFILE ]] && source "$ENVFILE"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/gaiz/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/gaiz/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/gaiz/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/gaiz/google-cloud-sdk/completion.zsh.inc'; fi

eval "$(mcfly init zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

