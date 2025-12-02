# Nix Configuration Guide

This dotfiles repository is gradually migrating from GNU Stow + Homebrew to Nix flakes + home-manager.

## Prerequisites

### Install Nix (if not already installed)

```bash
# Recommended: Determinate Systems installer (includes flakes by default)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**Alternative (official installer):**
```bash
sh <(curl -L https://nixos.org/nix/install)
```

## Quick Start

### Option 1: Using nix-darwin (Recommended for macOS)

1. **Check your architecture:**
   ```bash
   uname -m
   # arm64 = Apple Silicon (use aarch64)
   # x86_64 = Intel Mac (use x86_64)
   ```

2. **Generate flake.lock:**
   ```bash
   nix flake lock
   ```

3. **Build and activate the configuration:**
   ```bash
   # For Apple Silicon (M1/M2/M3):
   nix run nix-darwin -- switch --flake .#aarch64

   # For Intel Mac:
   nix run nix-darwin -- switch --flake .#x86_64
   ```

4. **For subsequent updates:**
   ```bash
   # Apple Silicon:
   darwin-rebuild switch --flake .#aarch64

   # Intel Mac:
   darwin-rebuild switch --flake .#x86_64
   ```

### Option 2: Using standalone home-manager

1. **Check your architecture:**
   ```bash
   uname -m
   # arm64 = Apple Silicon (use aarch64)
   # x86_64 = Intel Mac (use x86_64)
   ```

2. **Generate flake.lock:**
   ```bash
   nix flake lock
   ```

3. **Install home-manager (one-time):**
   ```bash
   nix run home-manager/master -- init --switch
   ```

4. **Activate the configuration:**
   ```bash
   # For Apple Silicon:
   home-manager switch --flake .#$USER-aarch64

   # For Intel Mac:
   home-manager switch --flake .#$USER-x86_64
   ```

## Dynamic Configuration

The configuration automatically detects:
- **Username**: Uses `$USER` environment variable
- **Home Directory**: Automatically set to `/Users/$USER`
- **Architecture**: Supports both Apple Silicon and Intel Macs

## Current Setup

### Packages Managed by Nix
- git

### Packages Still via Homebrew (see Brewfile)
- All other packages from Brewfile

### Dotfiles Management
- Existing dotfiles still managed via GNU Stow
- Gradually migrating to home-manager modules

## Adding More Packages

Edit `home.nix` and add packages to the `home.packages` list:

```nix
home.packages = with pkgs; [
  git
  neovim  # Add new packages here
  ripgrep
];
```

Then run:
```bash
# For nix-darwin:
darwin-rebuild switch --flake .#aarch64  # or .#x86_64

# For home-manager:
home-manager switch --flake .#$USER-aarch64  # or $USER-x86_64
```

## Updating Packages

```bash
# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Apply updates with nix-darwin:
darwin-rebuild switch --flake .#aarch64  # or .#x86_64

# OR with home-manager:
home-manager switch --flake .#$USER-aarch64  # or $USER-x86_64
```

## Rollback

If something breaks, you can rollback:

```bash
# List generations
darwin-rebuild --list-generations
# OR
home-manager generations

# Rollback to previous generation
darwin-rebuild rollback
# OR
home-manager switch --rollback
```

## Common Commands

```bash
# Check flake
nix flake check

# Show flake info
nix flake show

# Search for packages
nix search nixpkgs <package-name>

# Garbage collection (clean old generations)
nix-collect-garbage -d
```

## Migration Strategy (Option A - Gradual)

1. ✅ Install Nix
2. ✅ Create basic flake.nix + home.nix
3. ✅ Install git via Nix
4. 🔄 Incrementally add more packages to home.nix
5. 🔄 Migrate app configurations to home-manager modules when ready
6. 🔄 Eventually remove Brewfile and Makefile dependencies

## File Structure

```
dotfiles/
├── flake.nix           # Main Nix flake configuration
├── home.nix            # Home-manager user configuration
├── flake.lock          # Lock file (auto-generated, should commit)
├── Brewfile            # Legacy Homebrew packages (will phase out)
├── Makefile            # Legacy installation script (will phase out)
└── */                  # App-specific dotfiles (managed by stow for now)
```

## Troubleshooting

### "experimental feature 'nix-command' is disabled"
Enable flakes in `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

### Permission issues
Ensure your user is in the Nix trusted users list or has proper permissions.

### Architecture mismatch
Check your Mac architecture with `uname -m` and update `flake.nix` accordingly:
- `arm64` → `aarch64-darwin`
- `x86_64` → `x86_64-darwin`
