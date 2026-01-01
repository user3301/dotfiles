# Deployment Guide for Cross-Platform Dotfiles

This repository provides reproducible configurations for:
- **NixOS WSL2** (Windows Subsystem for Linux)
- **NixOS Native** (bare metal or VM)
- **Archlinux** with Nix + Home Manager
- **macOS** with nix-darwin (current setup)

## Directory Structure

```
dotfiles/
├── flake.nix                  # Main flake configuration
├── home/                      # Home Manager configurations
│   ├── modules/              # Shared modules
│   │   ├── common.nix        # Common settings
│   │   ├── shell.nix         # Shell configuration
│   │   ├── dev-tools.nix     # Development tools
│   │   ├── neovim.nix        # Neovim configuration
│   │   ├── terminal.nix      # Terminal multiplexers & emulators
│   │   └── editors.nix       # Other editors (helix)
│   ├── nixos-wsl.nix         # WSL2-specific home config
│   ├── nixos-native.nix      # Native NixOS home config
│   ├── archlinux.nix         # Archlinux home config
│   └── darwin.nix            # macOS home config
├── systems/                   # NixOS system configurations
│   ├── wsl/
│   │   └── configuration.nix # WSL2 system config
│   ├── native/
│   │   └── configuration.nix # Native NixOS system config
│   └── darwin/
│       └── configuration.nix # macOS system config
└── [app-configs]/            # Existing dotfiles (nvim, zellij, etc.)
```

## Prerequisites

All platforms need Nix with flakes enabled. Choose your platform:

### For NixOS (WSL2 or Native)
Nix is already installed. Ensure flakes are enabled in `/etc/nixos/configuration.nix`:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### For Archlinux or other Linux distributions
```bash
# Install Nix using Determinate Systems installer (recommended)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Or use official installer
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### For macOS
```bash
# Install Nix (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

## Bootstrap Process (First-Time Setup on Clean NixOS)

**The Chicken-and-Egg Problem**: On a fresh NixOS installation (WSL2 or Native), git is not installed by default, but you need git to clone the dotfiles repository. Here's how to solve this:

### Option 1: Using nix-shell (Traditional Method)

```bash
# Enter a temporary shell with git
nix-shell -p git

# Clone the dotfiles repo (while in nix-shell)
git clone https://github.com/user3301/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Deploy the configuration (git will be permanently installed after this)
sudo nixos-rebuild switch --flake .#nixos-wsl  # or .#nixos-native

# Exit the temporary shell
exit

# Now git is permanently installed as part of your system!
```

### Option 2: Using nix run (Modern Method)

```bash
# Clone using temporary git (no shell needed)
nix run nixpkgs#git -- clone https://github.com/user3301/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Deploy the configuration
sudo nixos-rebuild switch --flake .#nixos-wsl  # or .#nixos-native
```

**After the first deployment**, git is permanently installed as part of `environment.systemPackages`, so you can use it normally for updates:

```bash
cd ~/dotfiles
git pull
sudo nixos-rebuild switch --flake .#nixos-wsl
```

---

## Deployment Instructions

### 1. NixOS WSL2

**First-time setup on clean WSL2:**

```bash
# Step 1: Get temporary git access (choose one method from Bootstrap Process above)
nix-shell -p git

# Step 2: Clone the dotfiles repo
git clone https://github.com/user3301/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Step 3: Deploy the system configuration
sudo nixos-rebuild switch --flake .#nixos-wsl

# Step 4: Exit temporary shell
exit

# The system will have:
# - Configured WSL2 settings
# - Created user 'user3301'
# - Installed Home Manager packages
# - Symlinked all dotfiles
# - Permanently installed git and other system packages
```

**Subsequent updates:**
```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos-wsl
```

**Important Notes for WSL2:**
- Username is `user3301` (configured in `systems/wsl/configuration.nix`)
- Default shell is zsh
- WSL interoperability is enabled by default
- Windows paths are accessible via `/mnt/c/...`

### 2. NixOS Native

**First-time setup on clean NixOS:**

```bash
# Step 1: Get temporary git access (see Bootstrap Process above)
nix-shell -p git

# Step 2: Clone the dotfiles repo
git clone https://github.com/user3301/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Step 3: IMPORTANT - Generate hardware configuration first
sudo nixos-generate-config --show-hardware-config > ~/dotfiles/systems/native/hardware-configuration.nix

# Step 4: Edit systems/native/configuration.nix to uncomment the hardware import:
# imports = [ ./hardware-configuration.nix ];

# Step 5: Customize your setup in systems/native/configuration.nix:
#   - Choose display manager, desktop environment
#   - Configure graphics drivers
#   - Set hostname, timezone, locale

# Step 6: Deploy the system configuration
sudo nixos-rebuild switch --flake .#nixos-native

# Step 7: Exit temporary shell
exit
```

**Subsequent updates:**
```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos-native
```

**Customization:**
Before deploying, edit `systems/native/configuration.nix` to:
- Choose display manager (lightdm, gdm, etc.)
- Choose desktop environment (GNOME, KDE, i3, etc.)
- Configure graphics drivers (NVIDIA, AMD, Intel)
- Set timezone and locale
- Configure networking hostname

### 3. Archlinux with Nix + Home Manager

**First-time setup:**

```bash
# 1. Install Nix (if not already done)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. Edit home/archlinux.nix to set your actual username
# Change 'user3301' to your actual Arch username

# 4. Deploy Home Manager configuration
nix run home-manager/master -- switch --flake .#user@linux

# Note: Replace 'user@linux' with 'username@linux' if you changed the username
```

**Subsequent updates:**
```bash
cd ~/dotfiles
home-manager switch --flake .#user@linux
```

**Important Notes for Archlinux:**
- This is a **standalone Home Manager** setup (no NixOS)
- System packages should still be installed via `pacman`
- Nix manages development tools and user applications
- Username must match your actual Arch username
- Edit `home/archlinux.nix` to set correct username and home directory

### 4. macOS (Current Setup)

**First-time setup:**

```bash
# Already set up via nix-darwin
# Use existing Makefile commands:
make setup-mac
```

**Subsequent updates:**
```bash
darwin-rebuild switch --flake .#aarch64  # For Apple Silicon
# or
darwin-rebuild switch --flake .#x86_64   # For Intel Macs
```

## Configuration Customization

### Changing Username or Email

Edit the appropriate home configuration file:
- **WSL2**: `home/nixos-wsl.nix`
- **Native NixOS**: `home/nixos-native.nix`
- **Archlinux**: `home/archlinux.nix`
- **macOS**: `home/darwin.nix`

```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
};
```

### Adding New Packages

**System-wide packages (NixOS only):**
Edit `systems/{wsl,native}/configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  vim
  git
  # Add your packages here
];
```

**User packages (all platforms):**
Edit `home/modules/dev-tools.nix` or your platform-specific home config:
```nix
home.packages = with pkgs; [
  # Add your packages here
  htop
  docker
];
```

### Adding New Modules

Create a new module in `home/modules/` and import it in your platform configs:

```nix
# home/modules/mymodule.nix
{ config, pkgs, lib, ... }:
{
  # Your module configuration
}

# Then import in home/nixos-wsl.nix (or other configs)
imports = [
  ./modules/common.nix
  ./modules/mymodule.nix  # Add this
];
```

## Updating Flake Inputs

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Then rebuild your system
sudo nixos-rebuild switch --flake .#nixos-wsl  # or your config
```

## Troubleshooting

### Symlinks not working on Archlinux

On non-NixOS systems, Home Manager uses `mkOutOfStoreSymlink` which requires absolute paths. Ensure `config.home.homeDirectory` is set correctly in `home/archlinux.nix`.

### "conflicting files" error

Home Manager won't overwrite existing files. Either:
1. Backup and remove conflicting files: `mv ~/.config/nvim ~/.config/nvim.bak`
2. Or let Home Manager manage the files by using `home.file."path".force = true`

### WSL2 specific issues

**Permission denied on /etc/nixos:**
```bash
sudo mkdir -p /etc/nixos
sudo chown -R $USER:$USER /etc/nixos
```

**Windows paths not accessible:**
Ensure WSL interop is enabled in `systems/wsl/configuration.nix`:
```nix
wsl.interop.register = true;
```

### Flake evaluation errors

```bash
# Check for syntax errors
nix flake check

# Show detailed evaluation
nix flake show --allow-import-from-derivation
```

## Migration Strategy

### From existing non-Nix setup

1. **Backup existing configs**:
   ```bash
   mv ~/.config ~/.config.backup
   ```

2. **Deploy minimal configuration first**:
   Comment out modules in your home config and add them incrementally

3. **Test each module**:
   After adding each module, rebuild and verify it works

4. **Keep both systems during transition**:
   You can keep your old configs and gradually migrate

### From NixOS without flakes

1. **Enable flakes** in your current `/etc/nixos/configuration.nix`:
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

2. **Rebuild to enable flakes**:
   ```bash
   sudo nixos-rebuild switch
   ```

3. **Then switch to flake configuration**:
   ```bash
   cd ~/dotfiles
   sudo nixos-rebuild switch --flake .#nixos-wsl
   ```

## Platform-Specific Notes

### NixOS WSL2
- **Pros**: Full NixOS experience, declarative system config
- **Cons**: WSL2 limitations (no systemd by default, handled by nixos-wsl)
- **Use case**: Development environment on Windows

### NixOS Native
- **Pros**: Full system control, best Nix experience
- **Cons**: Learning curve, need to configure hardware
- **Use case**: Primary workstation, servers

### Archlinux + Nix/Home Manager
- **Pros**: Best of both worlds (pacman + Nix), gradual adoption
- **Cons**: Two package managers, can't configure system via Nix
- **Use case**: Already on Arch, want reproducible user environment

### macOS + nix-darwin
- **Pros**: Declarative package management on macOS
- **Cons**: Still need Homebrew for some GUI apps, macOS updates can break Nix
- **Use case**: Development on macOS

## Advanced Usage

### Testing configurations without switching

```bash
# NixOS
sudo nixos-rebuild test --flake .#nixos-wsl

# Home Manager
home-manager build --flake .#user@linux
./result/activate
```

### Building for different architecture

```bash
# Build for ARM64 from x86_64
nix build .#homeConfigurations.user@linux-arm64.activationPackage \
  --system aarch64-linux
```

### Using direnv (optional)

Create `.envrc` in project directories:
```bash
use flake
```

Then `direnv allow` to auto-load Nix environments.

## Support

For issues or questions:
1. Check the NixOS Wiki: https://nixos.wiki/
2. NixOS Discourse: https://discourse.nixos.org/
3. Home Manager Manual: https://nix-community.github.io/home-manager/

---

**Remember**: The beauty of this setup is reproducibility. Once configured, you can deploy identical environments across all your machines with a single command!
