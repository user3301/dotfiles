export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
# This is required for asdf (0.16 or later)
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

ZSH_THEME="random"

plugins=(git z colored-man-pages asdf vi-mode)

source $ZSH/oh-my-zsh.sh

# Vi-mode cursor: block for normal mode, beam for insert mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[2 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[6 q'
  fi
}
zle -N zle-keymap-select

function zle-line-init {
  echo -ne '\e[6 q'
}
zle -N zle-line-init

ENVFILE="$HOME/.zshenv"
[[ -s $ENVFILE ]] && source "$ENVFILE"

command -v mcfly &> /dev/null && eval "$(mcfly init zsh)"

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

# Auto-start herdr (launches or attaches to the persistent session)
if [[ $- == *i* ]] && [[ "$TERM_PROGRAM" != vscode ]] && [[ -z "$HERDR_ENV" ]] && command -v herdr &> /dev/null; then
	herdr
fi

# Run fastfetch when on every interactive terminal and NOT ssh into a machine
# if [[ $- == *i* ]] && [[ -z "$SSH_CONNECTION" ]]; then
#     fastfetch
# fi
