# Dotfiles Architecture

## Design Philosophy

This dotfiles repository is designed with the following principles:

1. **Reproducibility**: Identical environments across different machines and platforms
2. **Modularity**: Shared code between platforms, platform-specific overrides where needed
3. **Flexibility**: Support both NixOS (system-level) and non-NixOS (user-level) configurations
4. **Compatibility**: Preserve existing GNU Stow-compatible structure
5. **Separation of Concerns**: System configuration vs. user configuration

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        flake.nix                            │
│              (Entry point, defines all outputs)             │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   NixOS      │   │  Standalone  │   │  nix-darwin  │
│ Configuration│   │    Home      │   │   (macOS)    │
│              │   │   Manager    │   │              │
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ system cfg + │   │  home cfg    │   │ system cfg + │
│  home cfg    │   │    only      │   │  home cfg    │
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                            ▼
                ┌───────────────────────┐
                │   Home Manager        │
                │   Modules (Shared)    │
                │                       │
                │ • common.nix          │
                │ • shell.nix           │
                │ • dev-tools.nix       │
                │ • neovim.nix          │
                │ • terminal.nix        │
                │ • editors.nix         │
                └───────────────────────┘
                            │
                            ▼
                ┌───────────────────────┐
                │   Existing Dotfiles   │
                │   (Symlinked)         │
                │                       │
                │ • nvim/.config/nvim   │
                │ • zellij/.config/...  │
                │ • wezterm/.config/... │
                │ • etc.                │
                └───────────────────────┘
```

## Layer Breakdown

### Layer 1: Flake Entry Point

**File**: `/Users/gaiz/dotfiles/flake.nix`

- Defines all inputs (nixpkgs, home-manager, nixos-wsl, nix-darwin)
- Provides outputs for different configurations
- Contains helper functions (`mkSystem`, `mkHome`, `mkDarwin`)

**Outputs**:
- `nixosConfigurations.nixos-wsl`: WSL2 system + home config
- `nixosConfigurations.nixos-native`: Native NixOS system + home config
- `homeConfigurations.user@linux`: Standalone home config for Archlinux
- `darwinConfigurations.aarch64`: macOS system + home config

### Layer 2: System Configurations

**Purpose**: System-level settings (only on NixOS and macOS)

**Files**:
- `systems/wsl/configuration.nix`: WSL2-specific system config
- `systems/native/configuration.nix`: Native NixOS system config
- `systems/darwin/configuration.nix`: macOS system config (via nix-darwin)

**Responsibilities**:
- Boot configuration (native NixOS only)
- User account creation
- System packages (minimal)
- System services (SSH, networking, etc.)
- Platform-specific settings (WSL interop, macOS defaults, etc.)

**Key Decision**: Keep system packages minimal. Most packages go in Home Manager.

### Layer 3: Home Manager Configurations

**Purpose**: User-level settings and packages

**Files**:
- `home/nixos-wsl.nix`: WSL2 user config
- `home/nixos-native.nix`: Native NixOS user config
- `home/archlinux.nix`: Archlinux user config
- `home/darwin.nix`: macOS user config

**Responsibilities**:
- Import shared modules
- Set username and home directory
- Platform-specific packages
- Platform-specific overrides
- Git user configuration

### Layer 4: Shared Modules

**Purpose**: Reusable configuration modules

**Files** in `home/modules/`:

1. **common.nix**: Base configuration
   - Home Manager self-management
   - XDG directory structure
   - State version
   - Unfree packages allowance
   - Common environment variables
   - Minimal base packages

2. **shell.nix**: Shell configuration
   - Zsh with plugins
   - Sources existing .zshrc and .zshenv
   - Bash fallback

3. **dev-tools.nix**: Development packages
   - Git, gh, lazygit
   - Modern CLI tools (ripgrep, fd, bat, etc.)
   - Build tools
   - Nix development tools

4. **neovim.nix**: Neovim configuration
   - Enables neovim as default editor
   - Installs LSP servers and formatters
   - Symlinks existing nvim config

5. **terminal.nix**: Terminal multiplexers and emulators
   - Zellij configuration
   - Wezterm configuration
   - Yazi file manager
   - Symlinks to existing configs

6. **editors.nix**: Other editors
   - Helix configuration
   - LSP servers for Helix
   - Symlinks to existing config

**Design Pattern**: Each module is self-contained and can be independently enabled/disabled by commenting out the import.

### Layer 5: Existing Dotfiles

**Purpose**: Actual application configurations

**Structure**:
```
app-name/
  .config/
    app-name/
      config-files
```

This structure is compatible with GNU Stow and is symlinked by Home Manager using `mkOutOfStoreSymlink`.

**Why symlink instead of copy?**
- Allows editing configs directly without rebuilding
- Keeps configs in familiar locations
- Maintains git history in dotfiles repo
- Compatible with manual management if needed

## Configuration Flow

### NixOS WSL2 Deployment

```
1. User runs: sudo nixos-rebuild switch --flake .#nixos-wsl
                                              │
2. Nix evaluates flake.nix ─────────────────┘
                │
3. Loads nixosConfigurations.nixos-wsl
                │
4. Applies systems/wsl/configuration.nix
   - Creates user3301
   - Configures WSL settings
   - Enables zsh
                │
5. Loads Home Manager module (integrated)
                │
6. Evaluates home/nixos-wsl.nix
   - Sets username/home directory
   - Imports shared modules
                │
7. Each module does its job
   - Installs packages
   - Configures programs
   - Creates symlinks to existing dotfiles
                │
8. System is now configured!
```

### Archlinux Deployment

```
1. User runs: home-manager switch --flake .#user@linux
                                           │
2. Nix evaluates flake.nix ───────────────┘
                │
3. Loads homeConfigurations.user@linux
                │
4. Evaluates home/archlinux.nix
   - Sets username/home directory
   - Enables genericLinux target
   - Imports shared modules
                │
5. Each module does its job
   - Installs packages (to Nix profile)
   - Configures programs
   - Creates symlinks to existing dotfiles
                │
6. User environment is now configured!
   (System packages still managed by pacman)
```

## Key Architectural Decisions

### 1. Why separate system and home configurations?

**Reason**: Enables both full NixOS systems and non-NixOS systems (Archlinux) to share the same user-level configuration.

**Trade-off**: Slightly more complex structure, but much more flexible.

### 2. Why use mkOutOfStoreSymlink?

**Reason**: Allows editing dotfiles directly without Nix rebuilds. Configs remain in version control and can be modified interactively.

**Alternative**: Use `home.file."path".source = ./path` to copy files into Nix store (immutable, requires rebuild to change).

### 3. Why minimal system packages?

**Reason**:
- Portability: Same packages work on NixOS and non-NixOS
- Rollback: Home Manager rollbacks are faster and don't affect system
- Separation: Clear boundary between system and user concerns

**Exception**: System services and daemons should be in system config.

### 4. Why not use nix-darwin for everything on macOS?

**Reason**: Some macOS applications (especially GUI apps) are better managed via Homebrew due to notarization, automatic updates, and integration with macOS app store.

**Hybrid approach**:
- nix-darwin for system settings and CLI tools
- Homebrew for GUI applications (Brewfile)
- Home Manager for user-level dotfiles

### 5. Why flakes instead of channels?

**Reason**:
- **Reproducibility**: Flakes pin exact versions (flake.lock)
- **Composability**: Easy to combine inputs
- **Portability**: Self-contained, no channel state
- **Modern**: Official Nix direction

**Trade-off**: Requires Nix 2.4+ and experimental features enabled.

## Module Interaction

### Dependency Graph

```
common.nix (base, required)
    │
    ├── shell.nix (depends on common for home.homeDirectory)
    │       │
    │       └── Sources existing zsh configs
    │
    ├── dev-tools.nix (standalone)
    │       │
    │       └── Provides tools for other modules (gcc, etc.)
    │
    ├── neovim.nix (depends on dev-tools for LSPs)
    │       │
    │       └── Symlinks existing nvim config
    │
    ├── terminal.nix (standalone)
    │       │
    │       └── Symlinks existing terminal configs
    │
    └── editors.nix (depends on dev-tools for LSPs)
            │
            └── Symlinks existing helix config
```

### Avoiding Circular Dependencies

- **common.nix** has no dependencies
- **shell.nix** only reads from common
- Other modules can depend on common and dev-tools
- No module depends on terminal or editors (they're leaf nodes)

### Override Mechanism

Platform-specific configs can override any module setting:

```nix
# In home/nixos-wsl.nix
imports = [ ./modules/common.nix ];

# Override a setting from common.nix
home.sessionVariables.EDITOR = "helix";  # Override from "nvim"
```

## Extension Points

### Adding a New Platform

1. Create system config (if NixOS-based): `systems/newplatform/configuration.nix`
2. Create home config: `home/newplatform.nix`
3. Add to `flake.nix` outputs
4. Update DEPLOYMENT.md

### Adding a New Module

1. Create `home/modules/newmodule.nix`
2. Import in relevant platform configs
3. Document in DEPLOYMENT.md

### Adding Platform-Specific Packages

Option 1: In platform's home config:
```nix
# home/nixos-wsl.nix
home.packages = with pkgs; [ wsl-specific-tool ];
```

Option 2: Conditional in module:
```nix
# home/modules/dev-tools.nix
home.packages = with pkgs; [
  git
] ++ lib.optionals stdenv.isLinux [
  linux-specific-tool
];
```

### Adding System Services (NixOS only)

In system configuration:
```nix
# systems/native/configuration.nix
services.myservice = {
  enable = true;
  # configuration
};
```

## Security Considerations

### Secrets Management

**Current**: Git configuration includes email (public info)

**For secrets**: Consider using:
- **sops-nix**: Encrypted secrets in git
- **agenix**: Age-encrypted secrets
- **git-crypt**: Transparent git encryption
- **Local overrides**: `.zshenv.local` pattern (already in .gitignore)

### Unfree Packages

Currently enabled globally. To restrict:

```nix
# In relevant config
nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  "vscode"
  "slack"
];
```

## Performance Optimizations

### Build Caching

- **Binary cache**: nixos.org enabled by default
- **Local cache**: Nix store auto-optimizes with hard links
- **Flake lock**: Prevents re-downloading unchanged inputs

### Lazy Evaluation

- Modules are only evaluated if imported
- Unused platform configs don't slow down builds
- Conditional package installation uses `lib.optionals`

### Garbage Collection

System configs enable automatic GC (weekly, 7-day retention).

Manual GC:
```bash
# Delete generations older than 7 days
nix-collect-garbage --delete-older-than 7d

# Delete all old generations
nix-collect-garbage -d
```

## Testing Strategy

### Local Testing

```bash
# Test without switching
sudo nixos-rebuild test --flake .#nixos-wsl

# Build without activating
nix build .#nixosConfigurations.nixos-wsl.config.system.build.toplevel

# Check for errors
nix flake check
```

### CI/CD (Future)

Consider GitHub Actions:
```yaml
- name: Check flake
  run: nix flake check

- name: Build all configs
  run: |
    nix build .#nixosConfigurations.nixos-wsl.config.system.build.toplevel
    nix build .#homeConfigurations.user@linux.activationPackage
```

## Migration Path

### Phase 1: Minimal deployment (current)
- Basic system config
- Shared modules for dev tools
- Symlinks to existing dotfiles

### Phase 2: Enhance modules
- Add more language-specific tools
- Configure more applications via Nix
- Add platform-specific optimizations

### Phase 3: Advanced features
- Secrets management
- Custom NixOS modules
- Per-project development shells (flake.nix in projects)

### Phase 4: Full declarative system
- All applications via Nix
- Automated backups
- Declarative VM configurations

## Troubleshooting

### Common Issues

**Issue**: Symlinks conflict with existing files
**Solution**: Remove existing files or use `home.file."path".force = true`

**Issue**: Module not found
**Solution**: Check import path is relative to file location

**Issue**: Infinite recursion
**Solution**: Check for circular dependencies between modules

**Issue**: Package not found
**Solution**: Search at search.nixos.org, ensure correct attribute path

## Resources

- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **Home Manager Manual**: https://nix-community.github.io/home-manager/
- **Nix Pills**: https://nixos.org/guides/nix-pills/
- **Discourse**: https://discourse.nixos.org/

---

This architecture balances **reproducibility**, **flexibility**, and **pragmatism**. It allows you to maintain your existing workflow while gaining the benefits of declarative configuration management.
