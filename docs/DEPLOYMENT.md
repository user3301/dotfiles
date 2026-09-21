# Deployment Guide

| Platform | Packages | Dotfiles |
| --- | --- | --- |
| macOS | Homebrew Bundle using the root `Brewfile` | GNU Stow |
| Arch Linux | pacman using the root `pacman-packages.txt` | GNU Stow |
| NixOS WSL2 | Nix flake, `nixos-wsl` | Integrated Home Manager |
| Native NixOS | Nix flake, `nixos-native` | Integrated Home Manager |

Nix is not required or configured for macOS or Arch Linux. The native package
lists do not mirror the larger NixOS package set.

## Before installing

Review the configuration before using it on another machine. Back up individual
files that would conflict with symlinks; neither Stow nor Home Manager should
overwrite your existing configuration. Do not use `stow --adopt` unless you
intend to move existing files into this repository.

Keep the checkout at `~/dotfiles`. NixOS explicitly expects
`/home/user3301/dotfiles`, and the Zsh local override also uses `~/dotfiles`.
Do not run Stow on paths already managed by Home Manager.

For macOS and Arch Linux, start with Git installed and clone the repository:

```sh
git clone https://github.com/user3301/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

On macOS, Apple's Command Line Tools provide Git and Make; install them with
`xcode-select --install` if needed. On Arch Linux, install Git first with
`sudo pacman -Syu --needed git`. If Make is not yet available, use the direct
package installation commands below; the Arch list includes `base-devel`.

## macOS

Install [Homebrew](https://brew.sh/) if necessary (`make install-brew` runs its
installer). Follow the installer's shell setup instructions so `brew` is on
`PATH`; the prefix differs between Apple Silicon and Intel.

```sh
cd ~/dotfiles
brew bundle --file=Brewfile
```

The Brewfile installs GNU Stow, git-delta, Herdr, WezTerm, and AeroSpace. It does
not install the full NixOS toolchain or manage macOS system preferences.

Before enabling the Zsh configuration, read [Shell and application
dependencies](#shell-and-application-dependencies). Then preview and create links:

```sh
stow --simulate --verbose --target="$HOME" \
  bash fastfetch git herdr lazygit nvim wezterm yazi zsh aerospace
stow --target="$HOME" \
  bash fastfetch git herdr lazygit nvim wezterm yazi zsh aerospace
```

`make setup-mac` runs the Brewfile installation and Stow steps in order. It
requires Homebrew to be installed already and does not change your login shell.
On later updates, rerun `brew bundle --file=Brewfile` for manifest changes and
Stow when adding config files or packages.

## Arch Linux

Install the root package list using a full system upgrade, avoiding partial
upgrades:

```sh
cd ~/dotfiles
sudo pacman -Syu --needed - < pacman-packages.txt
```

The list includes Git, OpenSSH, Stow, Zsh, eza, Lazygit, fd, ripgrep, GitHub CLI,
xclip, `base-devel`, sudo, and which. It does not include every configured
application: for example, Neovim and delta need to be installed separately if
you use the editor and Git configurations.

After preparing the dependencies below, link the desired packages:

```sh
stow --simulate --verbose --target="$HOME" \
  bash fastfetch git herdr lazygit nvim wezterm yazi zsh
stow --target="$HOME" \
  bash fastfetch git herdr lazygit nvim wezterm yazi zsh
```

With Make available, `make setup-arch` installs the pacman list and then creates
these links. AeroSpace is macOS-only and is not included.

## Shell and application dependencies

Stow only creates links; it does not install applications or their dependencies.
Add desired macOS packages to `Brewfile`, or Arch packages to
`pacman-packages.txt`, and rerun the corresponding install command.

The shared Zsh config unconditionally loads Oh My Zsh from `~/.oh-my-zsh`.
On macOS and Arch Linux, install it before opening a shell with this config.
If that directory does not already exist:

```sh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
```

Zsh uses the `pygmalion` theme and the Git, z, colored-man-pages, asdf, and vi-mode
plugins. Its `ls` aliases require eza. Both shells select `nvim` as the editor,
so install Neovim or adjust the editor setting. McFly is optional; Bash also
uses zoxide when installed. The asdf plugin/shim path does not install asdf or
any language runtimes.

Git and Lazygit use delta. Configure your Git identity and signing key using
the [Git README](../git/.config/git/README.md). Language-server and formatter
dependencies are covered in the [Neovim README](../nvim/.config/nvim/README.md).
WezTerm's font configuration requests JetBrains Mono, Ubuntu Mono, and More
Perfect DOS VGA; install desired fonts separately on non-NixOS machines.

The default `make stow` selection is:
`bash fastfetch git herdr lazygit nvim wezterm yazi zsh`.
You can link a smaller subset:

```sh
make stow STOW_PACKAGES="git nvim"
```

`make setup-mac` adds `aerospace` to that selection. `vim` is another Stow
package, but it is not linked by default: its file is `~/.config/vim/vimrc`.
If your Vim does not discover that path, load it explicitly with
`vim -u ~/.config/vim/vimrc` or source it from your own `~/.vimrc`.

After installing Zsh, `make set-default-shell` registers it in `/etc/shells`
if needed and calls `chsh`. Log out and back in afterward.

### Migrating an existing Nix-managed macOS or Arch home

Removing this repository's old Nix configuration does not uninstall Nix or
remove links from a previously activated generation. Back up local overrides,
install native replacements, and retire the previous Home Manager/nix-darwin
setup using the tooling that created it before Stowing the same paths. Check
existing links with `ls -l`; do not let Stow write through an old Nix-managed
directory. NixOS homes should continue using Home Manager instead.

## NixOS WSL2

Start with an existing [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
distribution, not Ubuntu or another WSL distribution. From a user able to run
sudo:

```sh
nix --extra-experimental-features 'nix-command flakes' run github:user3301/dotfiles#bootstrap-wsl
```

The app in `scripts/bootstrap-nixos-wsl.sh` checks for WSL and `nixos-rebuild`,
then switches to `nixos-wsl-bootstrap`. That configuration creates `user3301`
and clones the repository to `/home/user3301/dotfiles` before Home Manager
activation. An existing Git checkout is left intact; an existing non-checkout
at that path is rejected. It can be rerun after an interrupted bootstrap.
`DOTFILES_FLAKE` overrides the rebuild's flake reference, not the clone URL.

From PowerShell, restart WSL:

```powershell
wsl --shutdown
```

Reopen as `user3301`, then use the normal output for subsequent changes:

```sh
cd ~/dotfiles
make switch
```

The WSL configuration enables Zsh, Docker, Windows interoperability, and
`nix-ld`; the SSH server is disabled. WezTerm is not installed or linked by this
home configuration: the terminal runs on the Windows host and must be configured
there separately.

For an existing checkout at the expected user path, `make setup-wsl-nixos` is
the alternate boot-staging workflow. It links the WSL system module into
`/etc/nixos/configuration.nix` and runs `nixos-rebuild boot --flake .#nixos-wsl`.
Restart WSL afterward. Continue using explicit `--flake` commands: that module
alone is not the full configuration.

## Native NixOS

This is a configuration for an already installed x86_64 NixOS system, not a disk
installer. It currently imports `systems/hardware/hardware-vb.nix`, which
contains VirtualBox-specific modules and filesystem UUIDs. **Replace that
hardware import before deploying to another machine.**

If Git is unavailable, obtain it temporarily with `nix-shell -p git`. Clone as
the intended user into `/home/user3301/dotfiles`, then:

```sh
cd ~/dotfiles
sudo nixos-generate-config --show-hardware-config > systems/native/hardware-configuration.nix
```

Change the `imports` entry in `systems/native/configuration.nix` from
`../hardware/hardware-vb.nix` to `./hardware-configuration.nix`. Add the new file
to Git so the local Git-backed flake can see it:

```sh
git add systems/native/hardware-configuration.nix
```

Review bootloader, user, hostname, networking, and graphics settings. The
current desktop uses X11, Qtile, and LightDM; NetworkManager and the SSH server
are enabled, with password and root SSH login disabled.

```sh
sudo nixos-rebuild build --flake .#nixos-native
sudo nixos-rebuild switch --flake .#nixos-native
```

If flakes are not enabled yet, pass the setting to the rebuild explicitly:

```sh
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild build --flake .#nixos-native
```

Use the same prefix for `switch`. The deployed configuration enables flakes
permanently.

Both NixOS outputs hard-code `user3301`. To change it, update the system user,
the matching `home-manager.users` key in `flake.nix`, and `home.username` and
`home.homeDirectory` in the selected home module. WSL bootstrap additionally
hard-codes its user and clone location in the flake and bootstrap script.

## Local settings and manual steps

The following local overrides are already ignored by Git:

| File | Loaded by |
| --- | --- |
| `git/.config/git/config.local` | Shared Git config, after the defaults |
| `zsh/.zshenv.local` | `~/.zshenv`, from `~/dotfiles` |
| `bash/.bashrc.local` | Interactive Bash, from `$DOTFILES/bash` |

Do not commit credentials or private keys. There is no automated secrets
provisioning.

Install Herdr's [Auto Title](https://github.com/kryptamine/herdr-auto-title) and
[reviewr](https://github.com/persiyanov/herdr-reviewr) plugins manually when using
Herdr. The tracked config binds `Alt+r` to reviewr; plugin state is ignored.
Herdr and Fastfetch auto-start snippets in `.zshrc` are commented out.

See [NixOS maintenance](README.nix.md) and the
[command reference](QUICK_REFERENCE.md) for updates and troubleshooting.
