# General environment variables
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
# reorder PATH to make sure Nix's home-manager PATH comes before
# system path, so it uses nix installed package first
export PATH="$HOME/.nix-profile/bin:$PATH"
export CLOUDSDK_PYTHON=/usr/bin/python3

# GPG TTY for commit signing. `tty` writes "not a tty" to stdout when stdin is
# not a terminal, so assign only on success and keep any inherited value.
if __tty=$(tty 2>/dev/null); then
  export GPG_TTY=$__tty
fi
unset __tty

# General aliases
alias v="nvim"

# eza as default lister (overrides oh-my-zsh's ls/ll/la aliases)
alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -l  --group-directories-first --icons=auto --git'
alias la='eza -la --group-directories-first --icons=auto --git'
alias lt='eza --tree --level=2 --icons=auto'

# Load local-specific configuration if it exists
[[ -f "$HOME/dotfiles/zsh/.zshenv.local" ]] && source "$HOME/dotfiles/zsh/.zshenv.local"
