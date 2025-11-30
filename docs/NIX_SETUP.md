# Nix Flake Setup for Dotfiles

This repository uses **Nix Flakes** and **home-manager** to provide reproducible, OS-agnostic configuration management.

Previously, this repo used GNU Stow to symlink dotfiles. Now, Nix manages both package installation and configuration files declaratively.

## Prerequisites

1. **Install Nix** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   The Determinate Systems installer automatically enables flakes and provides better defaults.

2. **For macOS users**: Install Homebrew for GUI apps
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   GUI applications like VS Code Insiders, Zed, and Aerospace are better managed via Homebrew casks.

## Quick Start

### 1. Clone the dotfiles repository
```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

### 2. Install GUI applications (macOS only)
```bash
brew bundle
```

### 3. Build and activate the home-manager configuration
```bash
nix run home-manager/master -- init --switch
# Or if home-manager is already available:
home-manager switch --flake .#
```

This will:
- Install oh-my-zsh automatically
- Install all required CLI packages (neovim, zsh, zellij, etc.)
- Link your configuration files to `~/.config/`
- Set up your shell environment with proper oh-my-zsh integration

## Using the Development Shell

For development or quick testing without activating the full configuration:

```bash
nix develop
```

This drops you into a shell with `home-manager`, `nix`, and `git` available.

## Updating Packages

To update all packages to the latest versions:
```bash
nix flake update
home-manager switch --flake .#
```

To update only specific packages, edit `nix/home.nix` and update the version constraints.

## Adding New Packages

1. Add the package to the `home.packages` list in `nix/home.nix`
2. Run `home-manager switch --flake .#`

Example:
```nix
home.packages = with pkgs; [
  # ... existing packages
  ripgrep
  fd
];
```

## Linking Additional Config Directories

To add configs for new apps, add entries to `nix/home.nix`:

```nix
xdg.configFile."your-app" = {
  source = "${dotfilesPath}/your-app/.config/your-app";
  recursive = true;
};
```

## Deploying to Multiple Machines

Since Nix is declarative, the same configuration works across:
- Linux (various distros)
- macOS
- NixOS

Simply:
1. Clone the repo
2. Run `nix flake update && home-manager switch --flake .#`

All packages and configs will be installed identically.

## Migration from GNU Stow

If you're migrating from the old GNU Stow setup:

1. **Remove old symlinks** (optional, home-manager will handle conflicts):
   ```bash
   # List current stow-managed symlinks
   stow -D -v nvim wezterm zsh zellij helix yazi
   ```

2. **Apply Nix configuration**:
   ```bash
   home-manager switch --flake .#
   ```

3. **Remove stow** (now managed by Nix):
   ```bash
   brew uninstall stow
   ```

## File Structure

```
dotfiles/
├── flake.nix                 # Nix flake entry point
├── nix/
│   ├── home.nix              # Main home-manager configuration
│   └── darwin.nix            # macOS-specific notes
├── Brewfile                  # GUI apps & fonts (macOS)
├── nvim/.config/nvim/        # Neovim configs
├── zsh/                      # Zsh config files (.zshrc, .zshenv)
├── wezterm/.config/wezterm/  # Wezterm config
├── zellij/.config/zellij/    # Zellij config
├── helix/.config/helix/      # Helix config
├── yazi/.config/yazi/        # Yazi config
├── aerospace/.config/aerospace/ # Aerospace window manager config
└── ...
```

## What's Managed Where

### Nix manages (declarative, reproducible):
- CLI tools: neovim, helix, bat, ripgrep, fd, fzf, jq, lazygit, yazi, zellij
- Shell: zsh with oh-my-zsh (automatically installed)
- Configuration files: symlinked to ~/.config/
- Development tools and their versions

### Homebrew manages (macOS GUI apps):
- GUI applications: wezterm, VS Code Insiders, Zed
- Window manager: Aerospace
- Special fonts: font-zed-mono

This hybrid approach gives you the best of both worlds:
- Reproducible CLI environment via Nix
- Native macOS app integration via Homebrew

## First Run Notes

### Neovim / LazyVim
On the first run of `nvim`, LazyVim will automatically:
1. Clone lazy.nvim plugin manager
2. Install LazyVim
3. Install all configured plugins

This is handled by the bootstrap code in `nvim/.config/nvim/lua/config/lazy.lua`.
Just wait for the installation to complete on first launch.

### Oh-My-Zsh
Oh-My-Zsh is automatically installed and configured by home-manager.
Your custom theme (`mikeh`) and plugins are declared in `nix/home.nix`.

## Troubleshooting

### "experimental-features not recognized"
Ensure you're using a recent version of Nix and have flakes enabled.

### Config files not linked
Run with verbose output:
```bash
home-manager switch --flake .# --verbose
```

### Package not found
Make sure the package name matches nixpkgs. Search at https://search.nixos.org/packages

### Neovim plugins not installing
On first run, neovim will bootstrap LazyVim. If this fails:
```bash
# Remove the lazy.nvim data directory and try again
rm -rf ~/.local/share/nvim/lazy
nvim
```

### Oh-My-Zsh theme not found
Home-manager installs oh-my-zsh automatically. If the `mikeh` theme isn't found,
ensure it's a built-in theme or add custom theme files to your config.

## Next Steps

- Customize `nix/home.nix` for your specific machine differences
- Add system-specific configurations (e.g., fonts, locale)
- Consider NixOS for full system reproducibility
