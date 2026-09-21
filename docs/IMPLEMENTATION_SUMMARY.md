# Current Configuration Summary

| Platform | Managed by this repository | Not managed |
| --- | --- | --- |
| NixOS WSL2 | System, integrated Home Manager, packages, mutable config links, bootstrap checkout | Windows terminal setup |
| Native NixOS | System, integrated Home Manager, packages, mutable config links | Automatic hardware discovery or disk installation |
| macOS | Brewfile package installation and GNU Stow links | Nix configuration or macOS system preferences |
| Arch Linux | Root pacman package list and GNU Stow links | Nix configuration or system services |

The NixOS outputs target x86_64. Linux x86_64 and ARM64 have repository quality
checks, a formatter, and a development shell. There are no standalone Home
Manager or Darwin outputs.

## Shared files, separate package sets

Application files remain Stow-compatible. NixOS links them with Home Manager's
`mkOutOfStoreSymlink`; macOS and Arch link them with Stow. NixOS expects the
checkout at `/home/user3301/dotfiles`.

The eight Home Manager modules cover common settings, shells, development
tools, Git, Neovim, terminal tools, WezTerm, and language toolchains. They are
used only by the NixOS homes. Native package manifests are independent and
smaller; installing one does not reproduce the entire NixOS environment.

Nix package sources are locked in `flake.lock`. Mutable config files,
Homebrew/pacman packages, Neovim plugin installation, Herdr plugins, and secrets
are not made reproducible by that lockfile.

CI already runs GitHub Actions linting, four Nix flake quality checks, and WSL
configuration evaluation. It does not deploy machines or install native
macOS/Arch packages.

## Documentation map

| Guide | Purpose |
| --- | --- |
| [Deployment](DEPLOYMENT.md) | Platform setup, hardware, dependencies, local overrides |
| [NixOS](README.nix.md) | Rebuilds, updates, rollback, garbage collection |
| [Architecture](ARCHITECTURE.md) | Modules, outputs, symlinks, CI |
| [Quick reference](QUICK_REFERENCE.md) | Common commands and file locations |
| [Version pinning](EXAMPLE-VERSION-PINNING.md) | Current Nix package overrides |
