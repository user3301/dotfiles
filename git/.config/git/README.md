# Git Configuration

This directory contains the shared git configuration that works across all platforms (NixOS, macOS, Linux, WSL).

## OS-Specific Configurations

You can create OS-specific git configuration files that will be automatically included:

### Setup

Add the following to the bottom of `config`:

```gitconfig
# OS-specific configurations
# These will be loaded if the files exist
[include]
	path = ~/.config/git/config.local
	path = ~/.config/git/config.darwin
	path = ~/.config/git/config.linux
	path = ~/.config/git/config.wsl
```

### Create OS-Specific Files

Then create the appropriate files:

- **`config.darwin`** - macOS-specific settings
- **`config.linux`** - Native Linux-specific settings
- **`config.wsl`** - WSL-specific settings
- **`config.local`** - Machine-specific settings (not tracked in git)

### Example OS-Specific Files

**config.darwin:**
```gitconfig
# macOS-specific git configuration

[core]
	# macOS specific settings
```

**config.linux:**
```gitconfig
# Linux-specific git configuration

[core]
	# Linux specific settings
```

**config.wsl:**
```gitconfig
# WSL-specific git configuration

[core]
	# WSL might need different autocrlf handling
```

### Notes

- Git will silently ignore include paths that don't exist
- Settings in later files override earlier ones
- You can add `config.local` to `.gitignore` for machine-specific settings
