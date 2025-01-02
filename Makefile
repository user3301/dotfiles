.DEFAULT_GOAL := all

.PHONY: all
all: install-brew install-brew-packages

.PHONY: install-brew
install-brew:
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.PHONY: install-brew-packages
install-brew-packages:
	brew bundle
