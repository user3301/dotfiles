# Quick Reference Guide

## Bootstrap (First-Time Setup on Clean NixOS)

**Problem**: No git on fresh NixOS install, but need git to clone dotfiles.

**Solution**:
```bash
# Get temporary git
nix-shell -p git
# or
nix run nixpkgs#git -- clone https://github.com/user3301/dotfiles.git ~/dotfiles

# Clone and deploy
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos-wsl  # or .#nixos-native
exit  # Exit nix-shell if used

# Now git is permanently installed!
```

See full bootstrap guide in [DEPLOYMENT.md](DEPLOYMENT.md#bootstrap-process-first-time-setup-on-clean-nixos).

---

## Common Commands by Platform

### NixOS WSL2

```bash
# Deploy/update system
sudo nixos-rebuild switch --flake .#nixos-wsl

# Test without switching
sudo nixos-rebuild test --flake .#nixos-wsl

# Build without activating
sudo nixos-rebuild build --flake .#nixos-wsl

# Show what will change
sudo nixos-rebuild dry-run --flake .#nixos-wsl

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### NixOS Native

```bash
# Deploy/update system
sudo nixos-rebuild switch --flake .#nixos-native

# Same options as WSL2 (test, build, dry-run, rollback)
```

### Archlinux (or other Linux with Home Manager)

```bash
# First-time setup (if home-manager not installed)
nix run home-manager/master -- switch --flake .#user@linux

# Update configuration
home-manager switch --flake .#user@linux

# Test without switching
home-manager build --flake .#user@linux
./result/activate

# List generations
home-manager generations

# Rollback
home-manager switch --rollback

# Or rollback to specific generation
/nix/var/nix/profiles/per-user/$USER/home-manager-42-link/activate
```

### macOS (nix-darwin)

```bash
# Deploy/update (Apple Silicon)
darwin-rebuild switch --flake .#aarch64

# Deploy/update (Intel)
darwin-rebuild switch --flake .#x86_64

# Using Makefile
make update-home-manager
```

## Flake Management

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
nix flake lock --update-input home-manager

# Show flake info
nix flake show

# Check for errors
nix flake check

# Show flake metadata
nix flake metadata
```

## Package Management

### Search for packages

```bash
# Online search (recommended)
# Visit: https://search.nixos.org/packages

# Command line search
nix search nixpkgs <package-name>

# Example
nix search nixpkgs neovim
```

### Install package temporarily

```bash
# Run without installing
nix run nixpkgs#hello

# Start shell with package
nix shell nixpkgs#hello nixpkgs#cowsay

# Run specific version
nix run github:nixos/nixpkgs/nixos-23.11#hello
```

### Add package permanently

Edit appropriate file:

**System packages** (NixOS only):
```nix
# systems/{wsl,native}/configuration.nix
environment.systemPackages = with pkgs; [
  mypackage
];
```

**User packages** (all platforms):
```nix
# home/modules/dev-tools.nix or platform-specific home config
home.packages = with pkgs; [
  mypackage
];
```

Then rebuild:
```bash
# NixOS
sudo nixos-rebuild switch --flake .#nixos-wsl

# Home Manager (Archlinux, etc.)
home-manager switch --flake .#user@linux
```

## Editing Configurations

### File locations

| What | Where |
|------|-------|
| Main flake | `/Users/gaiz/dotfiles/flake.nix` |
| WSL system | `/Users/gaiz/dotfiles/systems/wsl/configuration.nix` |
| Native system | `/Users/gaiz/dotfiles/systems/native/configuration.nix` |
| WSL home | `/Users/gaiz/dotfiles/home/nixos-wsl.nix` |
| Native home | `/Users/gaiz/dotfiles/home/nixos-native.nix` |
| Arch home | `/Users/gaiz/dotfiles/home/archlinux.nix` |
| Common module | `/Users/gaiz/dotfiles/home/modules/common.nix` |
| Dev tools | `/Users/gaiz/dotfiles/home/modules/dev-tools.nix` |

### Editing workflow

```bash
# 1. Edit configuration files
vim ~/dotfiles/home/modules/dev-tools.nix

# 2. Check for syntax errors
nix flake check

# 3. Test the changes
sudo nixos-rebuild test --flake .#nixos-wsl

# 4. If good, apply permanently
sudo nixos-rebuild switch --flake .#nixos-wsl

# 5. Commit changes
git add .
git commit -m "Add new package"
git push
```

## Dotfiles Management

### Symlinked configs

Your existing dotfiles are symlinked from:
- `~/dotfiles/nvim/.config/nvim` → `~/.config/nvim`
- `~/dotfiles/zellij/.config/zellij` → `~/.config/zellij`
- `~/dotfiles/wezterm/.config/wezterm` → `~/.config/wezterm`
- etc.

You can edit them directly:
```bash
# Edit neovim config
vim ~/dotfiles/nvim/.config/nvim/init.lua

# Changes are immediately available (no rebuild needed)
```

### Adding new dotfile

1. Add directory structure:
```bash
mkdir -p ~/dotfiles/myapp/.config/myapp
cp -r ~/.config/myapp/* ~/dotfiles/myapp/.config/myapp/
```

2. Create or update module:
```nix
# home/modules/myapp.nix
{ config, pkgs, lib, ... }:
{
  programs.myapp.enable = true;

  xdg.configFile."myapp".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/myapp/.config/myapp";
}
```

3. Import in home config:
```nix
# home/nixos-wsl.nix
imports = [
  ./modules/common.nix
  ./modules/myapp.nix
];
```

4. Rebuild

## Garbage Collection

```bash
# Delete old generations (7+ days)
nix-collect-garbage --delete-older-than 7d

# Delete all old generations (NixOS)
sudo nix-collect-garbage -d

# Delete all old generations (Home Manager)
nix-collect-garbage -d

# Remove old boot entries (NixOS)
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot

# Optimize store (remove duplicate files)
nix-store --optimise
```

## Troubleshooting

### Build failures

```bash
# Show detailed error
nix build --show-trace .#nixosConfigurations.nixos-wsl.config.system.build.toplevel

# Clean build cache
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

### Conflicting files

```bash
# Find conflicts
home-manager switch --flake .#user@linux

# If it shows conflicting files, back them up
mv ~/.config/nvim ~/.config/nvim.backup

# Then rebuild
home-manager switch --flake .#user@linux
```

### Rollback

```bash
# NixOS: List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# NixOS: Switch to generation 42
sudo nix-env --switch-generation 42 --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch

# Home Manager: List generations
home-manager generations

# Home Manager: Activate generation
/nix/var/nix/profiles/per-user/$USER/home-manager-42-link/activate
```

### Reset to clean state

```bash
# ⚠️  DESTRUCTIVE: This will remove all Nix-installed packages

# Remove all generations
nix-collect-garbage -d
sudo nix-collect-garbage -d

# Reinstall from scratch
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos-wsl
```

## Platform-Specific Quick Tips

### WSL2

```bash
# Access Windows files
cd /mnt/c/Users/YourName

# Run Windows command
cmd.exe /c dir

# Open file in Windows app
explorer.exe .
```

### Archlinux

```bash
# Update both Arch and Nix packages
sudo pacman -Syu && home-manager switch --flake .#user@linux

# Install system package (use pacman)
sudo pacman -S docker

# Install dev tool (use Nix)
# Add to home/modules/dev-tools.nix, then:
home-manager switch --flake .#user@linux
```

### macOS

```bash
# Update Homebrew apps
brew update && brew upgrade

# Update Nix configuration
darwin-rebuild switch --flake .#aarch64

# Both
brew upgrade && darwin-rebuild switch --flake .#aarch64
```

## Development Shells

### Project-specific environment

Create `flake.nix` in project directory:

```nix
{
  description = "My project";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs
          python3
          postgresql
        ];
      };
    };
}
```

Enter shell:
```bash
nix develop
```

Or use direnv:
```bash
echo "use flake" > .envrc
direnv allow
# Now auto-loads when you cd into directory
```

## Useful Environment Variables

```bash
# See what's in your PATH
echo $PATH

# See all Nix profiles
ls -la ~/.nix-profile/

# See current system profile (NixOS)
ls -la /run/current-system

# See current home-manager profile
ls -la ~/.local/state/home-manager/

# NIX_PATH (usually not needed with flakes)
echo $NIX_PATH
```

## Getting Help

```bash
# NixOS options search
https://search.nixos.org/options

# Home Manager options search
https://mipmip.github.io/home-manager-option-search/

# Nix command help
nix --help
nix build --help

# Man pages
man configuration.nix
man home-configuration.nix
```

## Cheat Sheet

| Task | NixOS | Home Manager (Arch) |
|------|-------|---------------------|
| Deploy | `sudo nixos-rebuild switch --flake .#nixos-wsl` | `home-manager switch --flake .#user@linux` |
| Test | `sudo nixos-rebuild test --flake .#nixos-wsl` | `home-manager build --flake .#user@linux; ./result/activate` |
| Rollback | `sudo nixos-rebuild switch --rollback` | `home-manager switch --rollback` |
| Update | `nix flake update` | `nix flake update` |
| GC | `sudo nix-collect-garbage -d` | `nix-collect-garbage -d` |
| List gens | `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system` | `home-manager generations` |

---

**Pro tip**: Alias common commands in your shell:

```bash
# Add to ~/.zshrc or equivalent
alias nrs="sudo nixos-rebuild switch --flake ~/dotfiles#nixos-wsl"
alias nrt="sudo nixos-rebuild test --flake ~/dotfiles#nixos-wsl"
alias hms="home-manager switch --flake ~/dotfiles#user@linux"
alias nfu="nix flake update"
```
