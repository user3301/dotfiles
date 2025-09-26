# General environment variables
export PATH="/opt/homebrew/opt/openssl/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export CLOUDSDK_PYTHON=/usr/bin/python3


# General aliases
alias vim="nvim"

# Proxy settings (can be overridden in .zshenv.local)
export {http,https,all}_proxy=http://localhost:3128
export {HTTP,HTTPS,ALL}_PROXY=$http_proxy

# Load work-specific configuration if it exists
[[ -f "$HOME/dotfiles/zsh/.zshenv.work" ]] && source "$HOME/dotfiles/zsh/.zshenv.work"

# Load local machine-specific configuration if it exists
[[ -f "$HOME/dotfiles/zsh/.zshenv.local" ]] && source "$HOME/dotfiles/zsh/.zshenv.local"
