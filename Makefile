.DEFAULT_GOAL := help

STOW_PACKAGES ?= bash fastfetch git herdr lazygit nvim wezterm yazi zsh

.PHONY: help
help:
	@echo "Dotfiles Setup Commands:"
	@echo ""
	@echo "Initial Setup:"
	@echo "  make setup-mac            - Install Brewfile packages and Stow dotfiles + AeroSpace"
	@echo "  make setup-arch           - Install pacman list and Stow dotfiles"
	@echo "  make stow                 - Symlink STOW_PACKAGES into your home directory"
	@echo "  make setup-wsl-nixos      - Stage NixOS WSL2 from an existing checkout (sudo)"
	@echo ""
	@echo "NixOS WSL2 Commands:"
	@echo "  make switch               - Rebuild NixOS system (slow, needs sudo)"
	@echo "  make build                - Build system without switching (test config)"
	@echo "  make update               - Update flake inputs"
	@echo "  make upgrade              - Update flake inputs and rebuild"
	@echo "  make generations          - List system generations"
	@echo "  make gc                   - Run garbage collection"
	@echo "  make clean                - Deep clean (delete old generations + gc)"
	@echo ""
	@echo "Other Commands:"
	@echo "  make set-default-shell    - Set zsh as default shell (requires sudo)"
	@echo "  make install-brew         - Install Homebrew (macOS only)"
	@echo "  make install-brew-packages - Install packages from Brewfile (macOS only)"
	@echo "  make install-arch-packages - Upgrade Arch and install pacman-packages.txt"
	@echo ""

.PHONY: set-default-shell
set-default-shell:
	@echo "Setting zsh as default shell..."
	@echo "This requires sudo access to modify /etc/shells"
	@ZSH_PATH=$$(which zsh); \
	if [ -z "$$ZSH_PATH" ]; then \
		echo "Error: zsh not found. Install it with your OS package manager first."; \
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
	brew bundle --file=Brewfile

.PHONY: install-arch-packages
install-arch-packages:
	@echo "Upgrading Arch Linux and installing packages..."
	sudo pacman -Syu --needed - < pacman-packages.txt

.PHONY: stow
stow:
	stow --dir="$(CURDIR)" --target="$(HOME)" $(STOW_PACKAGES)

.PHONY: setup-mac
setup-mac: install-brew-packages
	$(MAKE) stow STOW_PACKAGES="$(STOW_PACKAGES) aerospace"
	@echo "Brewfile packages installed and macOS dotfiles linked."

.PHONY: setup-arch
setup-arch: install-arch-packages
	$(MAKE) stow
	@echo "Pacman packages installed and Arch Linux dotfiles linked."

.PHONY: setup-wsl-nixos
setup-wsl-nixos:
	@echo "Setting up NixOS configuration for WSL2..."
	@DOTFILES_DIR=$$(pwd); \
	echo "Creating /etc/nixos directory..."; \
	sudo mkdir -p /etc/nixos; \
	echo "Creating symbolic link to $$DOTFILES_DIR/systems/wsl/configuration.nix"; \
	sudo ln -sf $$DOTFILES_DIR/systems/wsl/configuration.nix /etc/nixos/configuration.nix; \
	echo ""; \
	echo "Building NixOS configuration (staging for next boot)..."; \
	sudo nixos-rebuild boot --flake .#nixos-wsl; \
	echo ""; \
	echo "✅ NixOS configuration built and staged!"; \
	echo ""; \
	echo "Next steps:"; \
	echo "  1. Close this terminal"; \
	echo "  2. Run 'wsl --shutdown' in PowerShell"; \
	echo "  3. Reopen your NixOS WSL2 distro"; \
	echo "  4. Run 'cd ~/dotfiles && make switch' to verify"

# NixOS WSL2 specific targets
.PHONY: switch
switch:
	@echo "Rebuilding NixOS system..."
	sudo nixos-rebuild switch --flake .#nixos-wsl

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
	@echo "✅ Deep clean complete!"
