export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="sonicradish"

plugins=(git z colored-man-pages tmux asdf)

if [ "$TERM_PROGRAM" = 'ghostty' ] || [ "$TERM_PROGRAM" = 'WezTerm' ]
then
   ZSH_TMUX_AUTOSTART=true
   ZSH_TMUX_AUTOCONNECT=false
fi

source $ZSH/oh-my-zsh.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

ENVFILE="$HOME/.zshenv"
[[ -s $ENVFILE ]] && source "$ENVFILE"

eval "$(mcfly init zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

