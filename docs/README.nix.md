# Cross-Platform Dotfiles with Nix Flakes

Fully reproducible dotfiles configuration supporting:
- **NixOS WSL2** (Windows Subsystem for Linux)
- **NixOS Native** (bare metal or VM)
- **Archlinux** with Nix + Home Manager
- **macOS** with nix-darwin

> "Dotfiles managed by Nix: because spending 40 hours to save 4 minutes is a lifestyle. Fully reproducible - I've tested it on my Windows gaming rig (NixOS-WSL2), my wife's MacBook Air, and my own laptop (I use Arch BTW). If it works there, it'll work anywhere."

## Quick Start

Choose your platform:

### NixOS WSL2
```bash
git clone <your-repo> ~/dotfiles
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos-wsl
```

### NixOS Native
```bash
git clone <your-repo> ~/dotfiles
cd ~/dotfiles

# Generate hardware config first
sudo nixos-generate-config --show-hardware-config > systems/native/hardware-configuration.nix

# Edit systems/native/configuration.nix to uncomment hardware import
# Then deploy
sudo nixos-rebuild switch --flake .#nixos-native
```

### Archlinux + Nix/Home Manager
```bash
# Install Nix first
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

git clone <your-repo> ~/dotfiles
cd ~/dotfiles

# Edit home/archlinux.nix to set your username
# Then deploy
nix run home-manager/master -- switch --flake .#user@linux
```

### macOS (existing setup)
```bash
make setup-mac
```

## What's Included

### Development Tools
- **Editors**: Neovim, Helix
- **Terminal**: Zellij, Wezterm, Yazi
- **Shell**: Zsh with completion and syntax highlighting
- **Version Control**: Git, GitHub CLI, Lazygit
- **CLI Tools**: ripgrep, fd, bat, fzf, jq, and more
- **Language Servers**: For Nix, Lua, TypeScript, Python, Rust, Go

### Configuration Management
- **Modular**: Shared modules + platform-specific overrides
- **Symlinked**: Your existing dotfiles are symlinked (edit directly, no rebuild needed)
- **Reproducible**: Same environment across all machines
- **Declarative**: Everything in version control

## Directory Structure

```
dotfiles/
├── flake.nix                    # Main configuration entry point
│
├── home/                        # Home Manager configurations
│   ├── modules/                 # Shared modules
│   │   ├── common.nix          # Base settings
│   │   ├── shell.nix           # Zsh configuration
│   │   ├── dev-tools.nix       # Development packages
│   │   ├── neovim.nix          # Neovim + LSPs
│   │   ├── terminal.nix        # Zellij, Wezterm, Yazi
│   │   └── editors.nix         # Helix editor
│   │
│   ├── nixos-wsl.nix           # WSL2 home config
│   ├── nixos-native.nix        # Native NixOS home config
│   ├── archlinux.nix           # Archlinux home config
│   └── darwin.nix              # macOS home config
│
├── systems/                     # NixOS system configurations
│   ├── wsl/
│   │   └── configuration.nix   # WSL2 system config
│   ├── native/
│   │   └── configuration.nix   # Native NixOS system config
│   └── darwin/
│       └── configuration.nix   # macOS system config
│
├── [existing dotfiles]/         # Your actual configs
│   ├── nvim/.config/nvim/
│   ├── zellij/.config/zellij/
│   ├── wezterm/.config/wezterm/
│   ├── yazi/.config/yazi/
│   ├── helix/.config/helix/
│   └── zsh/
│
└── docs/
    ├── DEPLOYMENT.md           # Detailed deployment guide
    ├── ARCHITECTURE.md         # Architecture documentation
    └── QUICK_REFERENCE.md      # Command cheat sheet
```

## Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)**: Detailed deployment instructions for each platform
- **[ARCHITECTURE.md](ARCHITECTURE.md)**: Architecture design and rationale
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)**: Command cheat sheet and quick tips

## Common Tasks

### Update Configuration
```bash
# NixOS
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos-wsl

# Archlinux
cd ~/dotfiles
home-manager switch --flake .#user@linux
```

### Add New Package
Edit `home/modules/dev-tools.nix`:
```nix
home.packages = with pkgs; [
  # Add your package here
  htop
];
```
Then rebuild.

### Update All Packages
```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos-wsl  # or your config
```

### Rollback
```bash
# NixOS
sudo nixos-rebuild switch --rollback

# Home Manager
home-manager switch --rollback
```

## Platform-Specific Features

### NixOS WSL2
- Full NixOS experience on Windows
- WSL interoperability enabled
- Windows paths accessible via `/mnt/c/`
- Username: `user3301`

### NixOS Native
- Full system control
- Hardware configuration included
- Desktop environment support
- Username: `user3301`

### Archlinux + Nix/Home Manager
- Best of both worlds (pacman + Nix)
- System packages via pacman
- User packages via Nix
- Gradual migration path

### macOS + nix-darwin
- System settings via Nix
- GUI apps via Homebrew (Brewfile)
- User configs via Home Manager

## Design Principles

1. **Reproducibility**: Same command, same result, every time
2. **Modularity**: Shared code across platforms, platform-specific when needed
3. **Flexibility**: Works on NixOS and non-NixOS systems
4. **Familiarity**: Preserves your existing dotfiles structure
5. **Separation**: System vs. user configuration

## Advanced Features

### Secrets Management
**Current approach**: Manual management for simplicity
- Generate SSH keys manually on each machine: `ssh-keygen -t ed25519`
- Keep sensitive credentials outside version control
- Use local overrides (`.zshenv.local` pattern) for machine-specific secrets

### Development Shells
Create project-specific environments:
```nix
# In your project directory
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { nixpkgs, ... }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [ nodejs python3 ];
    };
  };
}
```

Then: `nix develop`

### CI/CD
Add GitHub Actions to test configurations:
```yaml
- name: Check flake
  run: nix flake check
```

## Troubleshooting

### "experimental features not enabled"
```bash
# NixOS: Add to configuration.nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Non-NixOS: Add to ~/.config/nix/nix.conf
experimental-features = nix-command flakes
```

### Conflicting files
```bash
# Backup existing configs
mv ~/.config/nvim ~/.config/nvim.backup

# Then rebuild
home-manager switch --flake .#user@linux
```

### Build errors
```bash
# Show detailed trace
nix build --show-trace .#nixosConfigurations.nixos-wsl.config.system.build.toplevel

# Clean and rebuild
nix-collect-garbage -d
sudo nixos-rebuild switch --flake .#nixos-wsl
```

## Migration Guide

### From existing non-Nix setup
1. Start with minimal configuration
2. Add modules incrementally
3. Test each change
4. Keep backups during transition

### From NixOS without flakes
1. Enable flakes in current config
2. Rebuild with `nixos-rebuild switch`
3. Clone this repo
4. Switch to flake: `sudo nixos-rebuild switch --flake .#nixos-wsl`

### From home-manager without flakes
1. Backup current config
2. Install from this repo
3. Gradually migrate custom settings

## Contributing

Feel free to:
- Report issues
- Suggest improvements
- Share your configurations
- Submit pull requests

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Wiki](https://nixos.wiki/)

## FAQ

**Q: Why Nix?**
A: Reproducibility, declarative configuration, and one package manager to rule them all.

**Q: Can I use this on Ubuntu/Fedora?**
A: Yes! Use the Archlinux configuration as a template (standalone Home Manager).

**Q: Do I need to use Nix for everything?**
A: No. You can keep using your OS package manager for system packages and use Nix for user-level tools.

**Q: What if I want to customize?**
A: All configurations are modular. Edit the relevant module or create a new one.

**Q: How do I update packages?**
A: `nix flake update` updates all inputs, then rebuild your configuration.

**Q: Can I test changes without breaking my system?**
A: Yes! Use `sudo nixos-rebuild test` or `home-manager build` to test first.

---

**Remember**: The goal is reproducibility. Once configured, you can deploy this exact environment on any new machine with a single command!
