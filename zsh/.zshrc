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

command -v atuin &> /dev/null && . "$HOME/.atuin/bin/env"
command -v atuin &> /dev/null && eval "$(atuin init zsh)"

# Open buffer line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# "y" shell wrapper for Yazi that changes the current working directory when exiting Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# eval "$(zellij setup --generate-auto-start zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

