.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Dotfiles Setup Commands:"
	@echo ""
	@echo "  make install-nix          - Install Nix package manager"
	@echo "  make setup-home-manager   - Bootstrap home-manager (first time setup)"
	@echo "  make update-home-manager  - Update home-manager configuration"
	@echo "  make set-default-shell    - Set zsh as default shell (requires sudo)"
	@echo "  make install-brew         - Install Homebrew (macOS only)"
	@echo "  make install-brew-packages- Install GUI apps via Homebrew (macOS only)"
	@echo "  make setup-mac            - Full setup for macOS (Nix + home-manager + Homebrew)"
	@echo "  make setup-linux          - Full setup for Linux (Nix + home-manager)"
	@echo "  make setup-wsl-nixos      - Link NixOS configuration for WSL2 (requires sudo)"
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

.PHONY: set-default-shell
set-default-shell:
	@echo "Setting zsh as default shell..."
	@echo "This requires sudo access to modify /etc/shells"
	@ZSH_PATH=$$(which zsh); \
	if [ -z "$$ZSH_PATH" ]; then \
		echo "Error: zsh not found. Run 'make setup-home-manager' first."; \
		exit 1; \
	fi; \
	echo "Found zsh at: $$ZSH_PATH"; \
	if ! grep -q "$$ZSH_PATH" /etc/shells 2>/dev/null; then \
		echo "Adding $$ZSH_PATH to /etc/shells..."; \
		echo $$ZSH_PATH | sudo tee -a /etc/shells; \
	else \
		echo "$$ZSH_PATH already in /etc/shells"; \
	fi; \
	echo "Changing default shell to zsh..."; \
	chsh -s $$ZSH_PATH; \
	echo ""; \
	echo "✅ Default shell changed to zsh!"; \
	echo "⚠️  Please log out and log back in for the change to take effect."

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

.PHONY: setup-wsl-nixos
setup-wsl-nixos:
	@echo "Setting up NixOS configuration for WSL2..."
	@DOTFILES_DIR=$$(pwd); \
	echo "Creating /etc/nixos directory..."; \
	sudo mkdir -p /etc/nixos; \
	echo "Creating symbolic link to $$DOTFILES_DIR/systems/wsl/configuration.nix"; \
	sudo ln -sf $$DOTFILES_DIR/systems/wsl/configuration.nix /etc/nixos/configuration.nix; \
	echo ""; \
	echo "✅ NixOS configuration linked!"; \
	echo "Run 'sudo nixos-rebuild switch' to apply the configuration."
