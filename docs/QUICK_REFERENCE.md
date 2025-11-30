# Quick Reference

## Common Commands

### Apply Configuration Changes
```bash
# After editing nix/home.nix
home-manager switch --flake .#
```

### Update All Packages
```bash
# Update flake inputs (nixpkgs, home-manager)
nix flake update

# Apply updates
home-manager switch --flake .#
```

### Add a New Package
1. Edit `nix/home.nix`
2. Add package to `home.packages`:
   ```nix
   home.packages = with pkgs; [
     # ... existing packages
     your-new-package
   ];
   ```
3. Apply: `home-manager switch --flake .#`

### Search for Packages
```bash
# Search nixpkgs
nix search nixpkgs <package-name>

# Or use the web interface
open https://search.nixos.org/packages
```

### Add a New Config Directory
1. Create your config in the appropriate directory structure
   ```
   your-app/.config/your-app/config.toml
   ```

2. Add to `nix/home.nix`:
   ```nix
   xdg.configFile."your-app" = {
     source = "${dotfilesPath}/your-app/.config/your-app";
     recursive = true;
   };
   ```

3. Apply: `home-manager switch --flake .#`

### Rollback to Previous Generation
```bash
# List generations
home-manager generations

# Rollback to previous
home-manager switch --flake .# --rollback
```

### Clean Old Generations
```bash
# Remove old generations (save disk space)
home-manager expire-generations "-30 days"

# Garbage collect
nix-collect-garbage -d
```

### Check Configuration
```bash
# Dry run (see what would change)
home-manager switch --flake .# --dry-run

# Show what's currently installed
home-manager packages
```

## Development Workflow

### Testing Configuration Changes
```bash
# Edit nix/home.nix
nvim nix/home.nix

# Preview changes
home-manager switch --flake .# --dry-run

# Apply if looks good
home-manager switch --flake .#
```

### Adding Zsh Plugins
```nix
programs.zsh = {
  oh-my-zsh = {
    plugins = [
      "git"
      "z"
      "your-new-plugin"  # Add here
    ];
  };
};
```

### Managing Neovim LSP/Tools
Option 1: Let Mason (within neovim) manage them
Option 2: Add to `programs.neovim.extraPackages` in `nix/home.nix`

```nix
programs.neovim = {
  extraPackages = with pkgs; [
    # Language servers
    lua-language-server
    rust-analyzer
    # Formatters
    stylua
    # Linters
    shellcheck
  ];
};
```

## Troubleshooting

### Config Not Updating
```bash
# Verify file is linked
ls -la ~/.config/nvim

# Force rebuild
home-manager switch --flake .# --recreate-lock-file
```

### Package Conflicts
```bash
# Check what's providing a command
which <command>

# If installed via both Nix and Homebrew, remove from Brewfile
```

### Neovim Issues
```bash
# Clear neovim cache
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim

# Restart neovim to re-bootstrap
nvim
```

### Zsh Not Loading Config
```bash
# Check zsh is from Nix
which zsh  # Should be /nix/store/...

# Verify oh-my-zsh was installed
ls -la ~/.oh-my-zsh
```

## File Locations

### Nix Files
- `flake.nix` - Flake definition
- `flake.lock` - Locked versions (auto-generated)
- `nix/home.nix` - Main configuration
- `nix/darwin.nix` - macOS notes

### Generated Files (Don't Edit)
- `~/.oh-my-zsh/` - Managed by home-manager
- `~/.config/nvim/` - Symlinked to your dotfiles
- `/nix/store/` - Immutable package store

### Your Dotfiles (Edit These)
- `nvim/.config/nvim/`
- `zsh/.zshrc`, `zsh/.zshenv`
- `wezterm/.config/wezterm/`
- `zellij/.config/zellij/`
- etc.

## Tips

1. **Always commit your changes** to git before major updates
2. **Use generations** - you can always rollback
3. **Test in a VM** if making major changes
4. **Keep Brewfile** for GUI apps - Nix's macOS app support is limited
5. **Update regularly** - `nix flake update` monthly
6. **Check logs** - `home-manager switch --flake .# --show-trace` for errors
