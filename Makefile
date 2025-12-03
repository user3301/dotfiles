.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Dotfiles Setup Commands:"
	@echo ""
	@echo "  make install-nix          - Install Nix package manager"
	@echo "  make setup-home-manager   - Bootstrap home-manager (first time setup)"
	@echo "  make update-home-manager  - Update home-manager configuration"
	@echo "  make install-brew         - Install Homebrew (macOS only)"
	@echo "  make install-brew-packages- Install GUI apps via Homebrew (macOS only)"
	@echo "  make setup-mac            - Full setup for macOS (Nix + home-manager + Homebrew)"
	@echo "  make setup-linux          - Full setup for Linux (Nix + home-manager)"
	@echo ""

.PHONY: install-nix
install-nix:
	@echo "Installing Nix package manager..."
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

.PHONY: setup-home-manager
setup-home-manager:
	@echo "Activating home-manager configuration..."
	@echo "Detecting system..."
	@if [ "$$(uname -s)" = "Darwin" ]; then \
		if [ "$$(uname -m)" = "arm64" ]; then \
			echo "Detected: macOS Apple Silicon"; \
			nix run nix-darwin -- switch --flake .#aarch64; \
		else \
			echo "Detected: macOS Intel"; \
			nix run nix-darwin -- switch --flake .#x86_64; \
		fi \
	else \
		if [ "$$(uname -m)" = "x86_64" ]; then \
			echo "Detected: Linux x86_64"; \
			nix run home-manager/master -- switch --flake .#$$USER-x86_64-linux; \
		else \
			echo "Detected: Linux ARM64"; \
			nix run home-manager/master -- switch --flake .#$$USER-aarch64-linux; \
		fi \
	fi

.PHONY: update-home-manager
update-home-manager:
	@echo "Updating home-manager configuration..."
	@if [ "$$(uname -s)" = "Darwin" ]; then \
		if [ "$$(uname -m)" = "arm64" ]; then \
			darwin-rebuild switch --flake .#aarch64; \
		else \
			darwin-rebuild switch --flake .#x86_64; \
		fi \
	else \
		if [ "$$(uname -m)" = "x86_64" ]; then \
			home-manager switch --flake .#$$USER-x86_64-linux; \
		else \
			home-manager switch --flake .#$$USER-aarch64-linux; \
		fi \
	fi

.PHONY: install-brew
install-brew:
	@echo "Installing Homebrew..."
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.PHONY: install-brew-packages
install-brew-packages:
	@echo "Installing Homebrew packages..."
	brew bundle

.PHONY: setup-mac
setup-mac: install-nix setup-home-manager install-brew install-brew-packages
	@echo ""
	@echo "✅ macOS setup complete!"
	@echo "Packages installed via Nix, GUI apps installed via Homebrew"

.PHONY: setup-linux
setup-linux: install-nix setup-home-manager
	@echo ""
	@echo "✅ Linux setup complete!"
	@echo "All packages and configs installed via Nix"
