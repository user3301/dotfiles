# General environment variables
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
# reorder PATH to make sure Nix's home-manager PATH comes before
# system path, so it uses nix installed package first
export PATH="$HOME/.nix-profile/bin:$PATH"
export CLOUDSDK_PYTHON=/usr/bin/python3

# GPG TTY for commit signing
export GPG_TTY=$(tty)

# General aliases
alias v="nvim"

# Load local-specific configuration if it exists
[[ -f "$HOME/dotfiles/zsh/.zshenv.local" ]] && source "$HOME/dotfiles/zsh/.zshenv.local"
