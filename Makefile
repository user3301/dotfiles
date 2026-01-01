.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Dotfiles Setup Commands:"
	@echo ""
	@echo "Initial Setup:"
	@echo "  make install-nix          - Install Nix package manager"
	@echo "  make setup-home-manager   - Bootstrap home-manager (first time setup)"
	@echo "  make setup-mac            - Full setup for macOS (Nix + home-manager + Homebrew)"
	@echo "  make setup-linux          - Full setup for Linux (Nix + home-manager)"
	@echo "  make setup-wsl-nixos      - Link NixOS configuration for WSL2 (requires sudo)"
	@echo ""
	@echo "NixOS WSL2 Commands:"
	@echo "  make switch               - Rebuild NixOS system (slow, needs sudo)"
	@echo "  make home-switch          - Rebuild home-manager only (fast, no sudo)"
	@echo "  make build                - Build system without switching (test config)"
	@echo "  make update               - Update flake inputs"
	@echo "  make upgrade              - Update flake inputs and rebuild"
	@echo "  make generations          - List system generations"
	@echo "  make home-generations     - List home-manager generations"
	@echo "  make gc                   - Run garbage collection"
	@echo "  make clean                - Deep clean (delete old generations + gc)"
	@echo ""
	@echo "Secrets Management:"
	@echo "  make secrets-check        - Check secrets setup status"
	@echo "  make secrets-init         - Generate age key for encryption"
	@echo "  make secrets-edit         - Edit encrypted secrets file"
	@echo "  make secrets-encrypt      - Encrypt secrets.yaml file"
	@echo "  make secrets-decrypt      - Decrypt and view secrets"
	@echo ""
	@echo "Other Commands:"
	@echo "  make set-default-shell    - Set zsh as default shell (requires sudo)"
	@echo "  make install-brew         - Install Homebrew (macOS only)"
	@echo "  make install-brew-packages- Install GUI apps via Homebrew (macOS only)"
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

# NixOS WSL2 specific targets
.PHONY: switch
switch:
	@echo "Rebuilding NixOS system..."
	sudo nixos-rebuild switch --flake .#nixos-wsl

.PHONY: home-switch
home-switch:
	@echo "Rebuilding home-manager configuration..."
	home-manager switch --flake .#nixos-wsl

.PHONY: build
build:
	@echo "Building NixOS system (without switching)..."
	sudo nixos-rebuild build --flake .#nixos-wsl

.PHONY: update
update:
	@echo "Updating flake inputs..."
	nix flake update

.PHONY: upgrade
upgrade: update switch
	@echo "✅ System upgraded!"

.PHONY: generations
generations:
	@echo "System generations:"
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

.PHONY: home-generations
home-generations:
	@echo "Home-manager generations:"
	home-manager generations

.PHONY: gc
gc:
	@echo "Running garbage collection..."
	nix-collect-garbage
	@echo "✅ Garbage collection complete!"

.PHONY: clean
clean:
	@echo "Deep cleaning old generations and running garbage collection..."
	@echo "Deleting system generations older than 7 days..."
	sudo nix-collect-garbage --delete-older-than 7d
	@echo "Deleting home-manager generations older than 7 days..."
	home-manager expire-generations "-7 days"
	@echo "✅ Deep clean complete!"

# Secrets Management
.PHONY: secrets-check
secrets-check:
	@echo "Checking secrets setup..."
	@if [ -f ~/.config/sops/age/keys.txt ]; then \
		echo "✅ Age key exists at ~/.config/sops/age/keys.txt"; \
		echo "Public key:"; \
		nix-shell -p age --run "age-keygen -y ~/.config/sops/age/keys.txt"; \
	else \
		echo "❌ Age key not found at ~/.config/sops/age/keys.txt"; \
		echo "Run: make secrets-init"; \
	fi
	@echo ""
	@if [ -f secrets/secrets.yaml ]; then \
		echo "✅ Secrets file exists"; \
		if grep -q "sops:" secrets/secrets.yaml && grep -q "age:" secrets/secrets.yaml; then \
			echo "✅ File is encrypted (safe to commit)"; \
		else \
			echo "❌ File is NOT encrypted (DO NOT commit!)"; \
			echo "Run: make secrets-encrypt"; \
		fi \
	else \
		echo "⚠️  Secrets file not found"; \
		echo "Copy secrets.yaml.example to secrets.yaml and edit it"; \
	fi

.PHONY: secrets-init
secrets-init:
	@echo "Initializing secrets management..."
	@mkdir -p ~/.config/sops/age
	@if [ -f ~/.config/sops/age/keys.txt ]; then \
		echo "Age key already exists"; \
	else \
		echo "Generating age key..."; \
		nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"; \
		echo ""; \
		echo "✅ Age key generated!"; \
		echo ""; \
		echo "Your public key:"; \
		nix-shell -p age --run "age-keygen -y ~/.config/sops/age/keys.txt"; \
		echo ""; \
		echo "⚠️  IMPORTANT: Update .sops.yaml with this public key!"; \
	fi

.PHONY: secrets-edit
secrets-edit:
	@if [ ! -f secrets/secrets.yaml ]; then \
		echo "Secrets file not found. Creating from template..."; \
		cp secrets/secrets.yaml.example secrets/secrets.yaml; \
		echo "Edit secrets/secrets.yaml and add your secrets, then run 'make secrets-encrypt'"; \
	else \
		nix-shell -p sops --run "sops secrets/secrets.yaml"; \
	fi

.PHONY: secrets-encrypt
secrets-encrypt:
	@if [ ! -f secrets/secrets.yaml ]; then \
		echo "Error: secrets/secrets.yaml not found"; \
		exit 1; \
	fi
	@echo "Encrypting secrets..."
	@nix-shell -p sops --run "sops -e -i secrets/secrets.yaml"
	@echo "✅ Secrets encrypted! Safe to commit to git."

.PHONY: secrets-decrypt
secrets-decrypt:
	@if [ ! -f secrets/secrets.yaml ]; then \
		echo "Error: secrets/secrets.yaml not found"; \
		exit 1; \
	fi
	@nix-shell -p sops --run "sops -d secrets/secrets.yaml"
