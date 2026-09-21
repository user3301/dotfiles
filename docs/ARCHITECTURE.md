# Dotfiles Architecture

## Platform boundaries

Application configuration is shared; package management is not.

```text
NixOS WSL2 / native                   macOS / Arch Linux
  flake.nix                            Brewfile / pacman-packages.txt
    systems/ + home/                     native package installation
      Home Manager symlinks              GNU Stow symlinks
                \                        /
                 shared application files
```

Only NixOS uses the Nix modules. macOS uses Homebrew Bundle and Stow; Arch Linux
uses pacman and Stow. Neither native package manifest promises the same package
set or exact versions as NixOS.

## Repository layout

| Path | Responsibility |
| --- | --- |
| `flake.nix`, `flake.lock` | NixOS outputs, pinned inputs, overlays, checks, development shells |
| `systems/wsl/configuration.nix` | WSL user, interoperability, Docker, nix-ld, system settings |
| `systems/native/configuration.nix` | Native boot, networking, X11/Qtile/LightDM, SSH |
| `systems/hardware/hardware-vb.nix` | Currently imported VirtualBox hardware and filesystem config |
| `home/nixos-wsl.nix`, `home/nixos-native.nix` | User identity, module imports, platform packages |
| `home/modules/` | Shared NixOS user packages and links |
| `scripts/bootstrap-nixos-wsl.sh` | One-time NixOS-WSL bootstrap app |
| `Brewfile`, `pacman-packages.txt` | Native macOS and Arch package lists |
| `Makefile` | Native package/Stow helpers and NixOS WSL maintenance commands |
| `.github/workflows/ci.yml` | Quality checks and WSL evaluation |
| Application directories | Stow-compatible, editable configuration |

Stow packages are `aerospace`, `bash`, `fastfetch`, `git`, `herdr`, `lazygit`,
`nvim`, `vim`, `wezterm`, `yazi`, and `zsh`. Most use
`<package>/.config/<application>/`; Bash and Zsh contain home-directory startup
files. AeroSpace is macOS-only. Vim's XDG config requires explicit loading on
Vim versions that do not discover it.

## Nix flake

The inputs are `nixpkgs` (NixOS 26.05), `home-manager` (release-26.05),
`nixos-wsl`, `claude-code-nix`, `herdr`, and a commit-pinned
`nixpkgs-azure-cli`. `flake.lock` records the resolved revisions.

`mkSystem` adds the Claude Code, Copilot CLI, and Azure CLI overlays to each
NixOS configuration. Home Manager uses `useGlobalPkgs = true`, so it receives
those same overlaid packages; `useUserPackages = true` installs home packages
through the NixOS user profile. The flake passes `inputs` to both module layers.
See [version pinning](EXAMPLE-VERSION-PINNING.md) for the package exceptions.

| Output | Scope |
| --- | --- |
| `nixosConfigurations.nixos-wsl` | x86_64 WSL system and home |
| `nixosConfigurations.nixos-wsl-bootstrap` | Same WSL configuration plus activation-time checkout creation |
| `nixosConfigurations.nixos-native` | x86_64 native system and home |
| `packages.x86_64-linux.bootstrap-wsl` | Packaged bootstrap shell script |
| `apps.x86_64-linux.bootstrap-wsl` | Runnable bootstrap entry point |
| `checks.<system>` | Nix quality, Lua format, Zsh syntax, Bash syntax |
| `formatter.<system>` | nixfmt |
| `devShells.<system>.default` | Repository editing and lint tools |

The checks, formatter, and development shell support `x86_64-linux` and
`aarch64-linux`. There is no ARM NixOS host output, no standalone Home Manager
output, and no Darwin output.

The bootstrap activation creates `/home/user3301/dotfiles` if absent, using a
Git clone owned by `user3301`. Both normal NixOS homes require that mutable
checkout; the native output does not create it.

## Home Manager modules

| Module | What it manages |
| --- | --- |
| `common.nix` | XDG, Home Manager CLI, editor/DOTFILES session variables, archive/download tools |
| `shell.nix` | Oh My Zsh, Bash completion, McFly, zoxide, Bash/Zsh startup symlinks |
| `dev-tools.nix` | CLI/build tools, Kubernetes/Azure tools, Nix tools, Claude Code, Copilot CLI, devcontainer |
| `git.nix` | Git, gh, Lazygit, delta, GPG agent, Git/Lazygit symlinks, gh SSH protocol |
| `neovim.nix` | Neovim, language servers, formatters, Tree-sitter tools, fswatch, Neovim symlink |
| `terminal.nix` | Herdr, Yazi and its integration settings, Herdr/Yazi/Fastfetch symlinks |
| `wezterm.nix` | WezTerm symlink; imported only by the native home |
| `languages.nix` | Go, Rust, .NET 8, Protobuf, Python, Node.js toolchains |

The WSL home adds PowerShell and sets `systemd.user.startServices = "suggest"`
so activation does not try to start user services before a normal WSL login.
The native home adds GnuPG, WezTerm, and Firefox. NixOS enables Zsh system-wide;
the shell module links the hand-written startup files rather than generating
them with Home Manager's shell programs.

## Mutable configuration and reproducibility

Home Manager uses `mkOutOfStoreSymlink` to link application directories or
startup files into `/home/user3301/dotfiles`. Stow links the same files on macOS
and Arch Linux. Editing a linked file changes the checkout immediately; reload
the application to pick it up. Adding a Nix module, package, or link requires a
NixOS rebuild; adding Stow-managed paths may require rerunning Stow.

Nix pins package sources, not the live contents of these symlinked files.
System rollback does not roll back mutable dotfiles. Neovim plugins have their
own `lazy-lock.json` and are downloaded by lazy.nvim, not provisioned by the
Nix flake. Herdr plugins and credentials are also managed separately.

Git identity/signing overrides and local shell settings are ignored by Git.
Herdr can write runtime state into its symlinked config directory; `.gitignore`
excludes those files. See [deployment](DEPLOYMENT.md#local-settings-and-manual-steps).

## Existing CI

`.github/workflows/ci.yml` runs on pushes to `master`, pull requests, and manual
dispatch. On Ubuntu it lints GitHub Actions, installs Nix, enables a binary
cache, builds the four `x86_64-linux` checks, and evaluates the WSL system
derivation:

```sh
nix build --no-link \
  .#checks.x86_64-linux.nix-quality \
  .#checks.x86_64-linux.lua-format \
  .#checks.x86_64-linux.zsh-syntax \
  .#checks.x86_64-linux.bash-syntax
nix eval --raw '.#nixosConfigurations.nixos-wsl.config.system.build.toplevel.drvPath'
```

Nix quality runs nixfmt, statix, and deadnix on Nix files. Lua formatting uses
StyLua for Neovim and WezTerm. Shell checks parse the Bash and Zsh startup
files. CI does not build full NixOS systems, evaluate the native host, install
Homebrew/pacman packages, or activate Stow links.

`nix develop` provides deadnix, Git, nil, nixfmt, statix, StyLua, Vim, and Zsh.
