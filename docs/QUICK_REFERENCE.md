# Quick Reference

Run checkout commands from `~/dotfiles`. Read [deployment](DEPLOYMENT.md) for
prerequisites and conflict handling before the first setup.

## macOS and Arch Linux

| Task | macOS | Arch Linux |
| --- | --- | --- |
| Install/update manifest packages | `brew bundle --file=Brewfile` | `sudo pacman -Syu --needed - < pacman-packages.txt` |
| Install packages and link dotfiles | `make setup-mac` | `make setup-arch` |
| Package manifest | `Brewfile` | `pacman-packages.txt` |

Homebrew must already be on `PATH` for `make setup-mac`. Stow does not install
shell frameworks or missing applications; the manifests are not the full NixOS
package set.

```sh
# Default non-AeroSpace links
make stow

# Select only desired packages
make stow STOW_PACKAGES="git nvim"

# Preview a selection
stow --simulate --verbose --target="$HOME" git nvim

# Remove only Stow-managed links for a selection
stow --delete --target="$HOME" git nvim

# macOS-only configuration
stow --target="$HOME" aerospace
```

`make stow` selects `bash fastfetch git herdr lazygit nvim wezterm yazi zsh`.
`make setup-mac` adds `aerospace`. Do not Stow paths managed by Home Manager.

## NixOS WSL2

```sh
# Bootstrap an existing NixOS-WSL installation
nix --extra-experimental-features 'nix-command flakes' run github:user3301/dotfiles#bootstrap-wsl

# After restarting WSL from PowerShell with wsl --shutdown:
cd ~/dotfiles
make switch

# Build without activation
make build

# Update locked inputs, then rebuild
make update
make switch
```

For an existing checkout, `make setup-wsl-nixos` stages the configuration with
`nixos-rebuild boot`; it requires a WSL restart.

## Native NixOS

Replace the VirtualBox hardware import before deploying to another machine.

```sh
sudo nixos-rebuild build --flake .#nixos-native
sudo nixos-rebuild switch --flake .#nixos-native
```

## Nix maintenance

```sh
nix flake show
nix flake check
nix develop
nix fmt -- flake.nix

nix flake update
nix flake update nixpkgs home-manager

sudo nixos-rebuild switch --rollback
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
nix-collect-garbage
```

`nixos-rebuild test --flake .#nixos-wsl` activates temporarily; `build` does not.
System rollback does not revert linked files in the mutable checkout.
`make clean` deletes generations older than seven days and runs GC; use it only
when those rollback points are no longer needed.

Home Manager is integrated into the NixOS rebuild, not exposed as a standalone
flake output.

## Where to edit

| Change | File |
| --- | --- |
| Nix inputs, overlays, outputs, checks | `flake.nix` |
| WSL system services/user | `systems/wsl/configuration.nix` |
| Native hardware import/desktop/services | `systems/native/configuration.nix` |
| NixOS user identity/platform packages | `home/nixos-wsl.nix`, `home/nixos-native.nix` |
| Shared NixOS user packages | `home/modules/` |
| Application settings | Respective Stow package |
| Local Git identity/signing | `git/.config/git/config.local` (ignored) |
| Local Zsh settings | `zsh/.zshenv.local` (ignored) |
| Local interactive Bash settings | `bash/.bashrc.local` (ignored) |

Reload applications after editing their linked config. Rebuild NixOS for Nix
changes; rerun Stow for new linked paths. Use `git add` for new files that a
Git-backed flake must include.

`make help` lists the available helpers. Full CI commands are in
[Architecture](ARCHITECTURE.md#existing-ci); package override details are in
[Version pinning](EXAMPLE-VERSION-PINNING.md).
