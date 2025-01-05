.DEFAULT_GOAL := all

.PHONY: all
all: install-brew install-brew-packages install-omz

.PHONY: install-omz
install-omz:
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

.PHONY: install-brew
install-brew:
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.PHONY: install-brew-packages
install-brew-packages:
	brew bundle
