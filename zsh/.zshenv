export {http,https,all}_proxy=http://localhost:3128
export {HTTP,HTTPS,ALL}_PROXY=$http_proxy
export PATH="/opt/homebrew/opt/openssl/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export CLOUDSDK_PYTHON=/usr/bin/python3

export SPANNER_EMULATOR_HOST=localhost:9010

# Aliases
alias noproxy="unset http_proxy && unset https_proxy && unset HTTP_PROXY && unset HTTPS_PROXY"
alias vim="nvim"
alias gauth="gcloud auth login --update-adc"

export GLOBAL_ROOT_CA_CERT=~/.ssl/anz_ca_bundle.pem # Well-known environment variable
export CURL_CA_BUNDLE=~/.ssl/anz_ca_bundle.pem # For curl export 
export REQUESTS_CA_BUNDLE=~/.ssl/anz_ca_bundle.pem # For python Requests export 
export SSL_CERT_FILE=~/.ssl/anz_ca_bundle.pem # For misc system tools export 
export HTTPLIB2_CA_CERTS=~/.ssl/anz_ca_bundle.pem # For python httplib2 export 
export GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=~/.ssl/anz_ca_bundle.pem # For gRPC-based libraries

export PATH="$HOME/go/bin:$PATH"
export GONOSUMDB='github.service.anz/*,github.com/anzx/*'
export GOPRIVATE='github.service.anz/*,github.com/anzx/*'
export GOPROXY='https://platform-gomodproxy.services.x.gcp.anz,direct'
