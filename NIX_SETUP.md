# Nix Flake Setup for Dotfiles

This repository now uses **Nix** and **home-manager** to provide reproducible configuration across different machines.

## Prerequisites

1. **Install Nix** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Enable Nix Flakes** (add to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`):
   ```
   experimental-features = nix-flakes nix-command
   ```

## Quick Start

### 1. Clone the dotfiles repository
```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

### 2. Build and activate the home-manager configuration
```bash
nix flake update
home-manager switch --flake .#
```

This will:
- Install all required packages (neovim, wezterm, zsh, zellij, etc.)
- Link your configuration files to `~/.config/`
- Set up your shell environment

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

## File Structure

```
dotfiles/
├── flake.nix                 # Nix flake entry point
├── nix/
│   └── home.nix              # home-manager configuration
├── nvim/.config/nvim/        # Neovim configs
├── zsh/.zshrc               # Zsh config
├── wezterm/.config/wezterm/  # Wezterm config
├── zellij/.config/zellij/    # Zellij config
├── helix/.config/helix/      # Helix config
├── yazi/.config/yazi/        # Yazi config
└── ...
```

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

## Next Steps

- Customize `nix/home.nix` for your specific machine differences
- Add system-specific configurations (e.g., fonts, locale)
- Consider NixOS for full system reproducibility
