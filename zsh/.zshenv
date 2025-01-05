export {http,https,all}_proxy=http://localhost:3128
export {HTTP,HTTPS,ALL}_PROXY=$http_proxy
export PATH="/opt/homebrew/opt/openssl/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export CLOUDSDK_PYTHON=/usr/bin/python3

export SPANNER_EMULATOR_HOST=localhost:9010
. "$HOME/.cargo/env"

# Aliases
alias noproxy="unset http_proxy && unset https_proxy && unset HTTP_PROXY && unset HTTPS_PROXY"
alias vim="lvim"
alias gauth="gcloud auth login --update-adc"

