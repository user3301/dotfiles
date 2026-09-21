# NixOS Dotfiles

Nix manages **native NixOS and NixOS WSL2 only**. For macOS (Homebrew + Stow) or
Arch Linux (pacman + Stow), use the [deployment guide](DEPLOYMENT.md).

## First deployment

The repository includes `flake.lock`; use those revisions for the initial
deployment rather than updating inputs immediately.

On an existing NixOS-WSL distribution:

```sh
nix --extra-experimental-features 'nix-command flakes' run github:user3301/dotfiles#bootstrap-wsl
```

This creates the `user3301` configuration and clones the mutable checkout into
`/home/user3301/dotfiles` before Home Manager activation. Restart with
`wsl --shutdown` from PowerShell and reopen the distribution.

For native NixOS, first clone the checkout and replace the checked-in
VirtualBox hardware import as described in
[Native NixOS deployment](DEPLOYMENT.md#native-nixos). Then:

```sh
sudo nixos-rebuild switch --flake .#nixos-native
```

Both host configurations are x86_64 and integrate Home Manager. There is no
separate `home-manager switch --flake` workflow. Most packages and application
links are defined in `home/modules/`; system settings are under `systems/`.

## Editing and applying changes

```sh
cd ~/dotfiles

# WSL: rebuild the system and integrated home together
make switch

# Native NixOS
sudo nixos-rebuild switch --flake .#nixos-native
```

Edit shared user packages in the appropriate `home/modules/*.nix` file, or
platform packages in `home/nixos-wsl.nix` / `home/nixos-native.nix`. Add new
modules to the selected home's imports. Git-backed flakes exclude new,
untracked files until they are added with `git add`.

Application configuration is linked to the checkout, so editing Lua, TOML,
shell, or Git config normally only needs an application reload. Do not Stow
over the links managed by Home Manager. Git identity belongs in the ignored
`git/.config/git/config.local`, not a generated `programs.git` configuration.

Keep `system.stateVersion` and `home.stateVersion` at their existing values
unless you have reviewed the relevant migration guidance. They select
compatibility defaults; they are not the package channel version.

## Updating packages

```sh
cd ~/dotfiles
nix flake update                  # all inputs
# Or update only selected inputs:
nix flake update nixpkgs home-manager

sudo nixos-rebuild switch --flake .#nixos-wsl
# Use .#nixos-native for the native host
```

Review and commit `flake.lock` alongside intentional input changes. Updating
the lockfile alone does not activate packages. The Azure CLI revision and
Copilot CLI version/hash override require deliberate edits; see
[version pinning](EXAMPLE-VERSION-PINNING.md).

`make update` updates inputs; `make upgrade` updates and rebuilds WSL.
`make switch`, `make build`, and `make upgrade` are WSL-specific, not host
auto-detection commands.

## Validation and troubleshooting

```sh
nix flake show
nix flake check

# Build without activation
sudo nixos-rebuild build --flake .#nixos-wsl

# Evaluate with a trace if necessary
nix eval --show-trace --raw \
  '.#nixosConfigurations.nixos-wsl.config.system.build.toplevel.drvPath'
```

`nixos-rebuild test` **does activate** the configuration, but does not make it
the boot default. Use `build` when you want no running-system changes.

CI's narrower quality/evaluation commands are listed in
[Architecture](ARCHITECTURE.md#existing-ci). Native hardware must be reviewed
on the target machine even if evaluation succeeds.

For initial commands on a system without flakes enabled, use
`nix --extra-experimental-features 'nix-command flakes' ...`. The bootstrap app
also enables those features for its rebuild.

If Home Manager reports a file conflict, inspect and back up that specific
path, then rebuild. Do not force replacement of the entire `~/.config`
directory. Inspect activation failures with:

```sh
journalctl -u home-manager-user3301.service -b
```

## Rollback and garbage collection

```sh
sudo nixos-rebuild switch --rollback
make generations
make gc
```

Integrated Home Manager packages and generated configuration belong to the
system generation. Mutable symlink targets are not rolled back; restore
application files separately from Git if necessary.

Both NixOS systems enable weekly garbage collection with seven-day retention.
`make clean` runs `sudo nix-collect-garbage --delete-older-than 7d`; this removes
older system generations and can eliminate rollback options. It is not a
build-error recovery step.

## Manual components

LazyVim downloads plugins independently of Nix. Herdr's Auto Title and reviewr
plugins need manual installation. SSH keys, signing keys, and credentials are
not provisioned. See [deployment](DEPLOYMENT.md#local-settings-and-manual-steps)
and the [Neovim README](../nvim/.config/nvim/README.md).
