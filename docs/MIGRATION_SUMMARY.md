# Migration Summary: GNU Stow → Nix Flakes

## What Changed

### Before (GNU Stow)
- Manual package installation via Homebrew
- GNU Stow for symlinking dotfiles
- Manual oh-my-zsh installation
- Manual LazyVim setup

### After (Nix Flakes + home-manager)
- **Declarative package management** via Nix
- **Automatic configuration linking** via home-manager
- **Built-in oh-my-zsh management** with automatic installation
- **LazyVim auto-bootstraps** on first neovim run
- **Cross-platform support** - same config works on Linux and macOS

## Updated Files

### New Files
- `flake.nix` - Nix flake entry point with proper system detection
- `nix/home.nix` - Complete home-manager configuration
- `nix/darwin.nix` - macOS-specific notes

### Modified Files
- `Brewfile` - Now only contains GUI apps and fonts
- `NIX_SETUP.md` - Comprehensive setup documentation

### Unchanged
- All dotfiles in their original locations (nvim, zsh, wezterm, etc.)
- Your actual configuration files remain the same

## Key Features

### 1. Oh-My-Zsh Integration
```nix
programs.zsh = {
  enable = true;
  oh-my-zsh = {
    enable = true;           # Automatically installs oh-my-zsh
    theme = "mikeh";
    plugins = [ "git" "z" "colored-man-pages" "asdf" "vi-mode" ];
  };
}
```

### 2. LazyVim Bootstrap
- Your existing `lua/config/lazy.lua` handles automatic installation
- First run of `nvim` will clone lazy.nvim and install all plugins
- No manual intervention needed

### 3. Configuration File Linking
All your configs are automatically symlinked:
- `~/.config/nvim` → dotfiles/nvim/.config/nvim
- `~/.config/wezterm` → dotfiles/wezterm/.config/wezterm
- `~/.config/zellij` → dotfiles/zellij/.config/zellij
- `~/.config/yazi` → dotfiles/yazi/.config/yazi
- `~/.config/helix` → dotfiles/helix/.config/helix
- `~/.config/aerospace` → dotfiles/aerospace/.config/aerospace

### 4. Package Management Split

**Nix manages (cross-platform CLI tools):**
- neovim, helix, bat, ripgrep, fd, fzf, jq, lazygit, yazi, zellij
- zsh with oh-my-zsh
- Nerd Fonts (JetBrains Mono)

**Homebrew manages (macOS-only GUI apps):**
- wezterm, VS Code Insiders, Zed, Aerospace
- font-zed-mono

## How to Use

### On Current Machine
```bash
# Apply the new Nix configuration
home-manager switch --flake .#

# Install GUI apps (macOS)
brew bundle
```

### On New Machine
```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone dotfiles
git clone <repo-url> ~/dotfiles && cd ~/dotfiles

# macOS: Install Homebrew and GUI apps
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle

# Apply configuration
home-manager switch --flake .#

# Launch neovim to bootstrap LazyVim (first time only)
nvim
```

## Benefits

1. **Reproducibility**: Same environment on any machine
2. **Version Control**: All packages and configs in git
3. **Atomic Updates**: Rollback if something breaks
4. **Cross-Platform**: Works on Linux and macOS
5. **No Manual Setup**: Oh-my-zsh and LazyVim install automatically
6. **Declarative**: Everything is defined in code

## What You Can Remove

After verifying the Nix setup works:
- `Makefile` (no longer needed)
- GNU Stow (can uninstall: `brew uninstall stow`)
- Manual oh-my-zsh installation script

## Next Steps

1. Test the configuration: `home-manager switch --flake .#`
2. Verify all configs are linked: `ls -la ~/.config/`
3. Test neovim: `nvim` (LazyVim will bootstrap)
4. Customize `nix/home.nix` for machine-specific needs
5. Add more packages as needed to `home.packages`

## Rollback

If something goes wrong:
```bash
# Rollback to previous generation
home-manager generations
home-manager switch --flake .# --rollback

# Or restore old Stow method temporarily
stow nvim wezterm zsh zellij helix yazi
```
