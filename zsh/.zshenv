# General environment variables
export PATH="/opt/homebrew/opt/openssl/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export CLOUDSDK_PYTHON=/usr/bin/python3

# General aliases
alias vim="nvim"
alias v="nvim"

# Load local-specific configuration if it exists
[[ -f "$HOME/dotfiles/zsh/.zshenv.local" ]] && source "$HOME/dotfiles/zsh/.zshenv.local"
