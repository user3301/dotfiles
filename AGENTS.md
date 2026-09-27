# AGENTS.md

Instructions for AI coding agents working in this repository. Humans should
start with `README`. The guides in `docs/` have the full details.

## What this repo is

Personal dotfiles for four platforms. Application config files are shared
across all of them; package management is not.

| Platform | Packages | Config files linked by |
| --- | --- | --- |
| NixOS WSL2 (`nixos-wsl`, the main machine) | `flake.nix` + integrated Home Manager | `mkOutOfStoreSymlink` in `home/modules/` |
| Native NixOS (`nixos-native`) | `flake.nix` + integrated Home Manager | `mkOutOfStoreSymlink` in `home/modules/` |
| macOS | `Brewfile` | GNU Stow |
| Arch Linux | `pacman-packages.txt` | GNU Stow |

Nix is used only on NixOS. There is no nix-darwin, no standalone Home Manager
configuration, and no ARM host.

## Layout

| Path | What goes there |
| --- | --- |
| `flake.nix` | Inputs, overlays and package pins, `mkSystem`, checks, dev shell |
| `systems/wsl/`, `systems/native/` | NixOS system settings for each host |
| `home/modules/*.nix` | Home Manager packages and config links, one topic per module |
| `home/nixos-wsl.nix`, `home/nixos-native.nix` | Each host's module imports and host-only packages |
| `<app>/.config/<app>/` | The application's real config files (Stow package layout) |
| `bash/`, `zsh/` | Shell startup files, linked directly into `$HOME` |
| `docs/` | User documentation describing the current setup |

## Hard rules

- **Never change `system.stateVersion` or `home.stateVersion`.** They select
  compatibility defaults, not the package release.
- **Keep application config hand-written and Stow-compatible.** macOS and Arch
  use the same files without Nix. Don't convert a config to Home
  Manager-generated settings (`programs.git.settings`, `programs.zsh`,
  `programs.neovim`, `programs.<app>.settings`, and so on). Link the repo files
  with `config.lib.file.mkOutOfStoreSymlink`, as the existing modules do.
- **Home Manager's shell modules are off** (`programs.zsh` and `programs.bash`
  are not enabled). Options that inject into them, such as
  `enableZshIntegration` or `home.shellAliases`, do nothing.
  `home.sessionVariables` only reaches shells that source `hm-session-vars.sh`
  (`bash/.bashrc` does). Put environment variables, aliases and shell
  integrations in `zsh/.zshenv` or `zsh/.zshrc`, and mirror them in
  `bash/.bashrc`.
- **Shell files must run on NixOS, Arch and macOS**, including macOS's bash
  3.2. Guard optional tools with `command -v`, and never reference
  `/nix/store` paths.
- **Don't apply system changes unless the user asks.** That covers
  `nixos-rebuild switch|boot|test`, `make switch|upgrade|clean|gc|setup-*`,
  `stow`, and anything run with `sudo`. Note that `nixos-rebuild test` does
  activate the configuration.
- **Don't update flake inputs unless asked.** Never run a bare
  `nix flake update`. Update only the named inputs
  (`nix flake update <input>`), and keep `flake.lock` changes in the same
  commit as the change that needs them.
- **Never commit secrets.** The `*.local` override files
  (`git/.config/git/config.local`, `zsh/.zshenv.local`, `bash/.bashrc.local`)
  are gitignored on purpose.
- **Herdr writes into its linked config directory.** Only
  `herdr/.config/herdr/config.toml` is tracked, and Herdr itself may edit it.
  Don't commit or revert changes there that you didn't make.
- **Neovim plugins are managed by lazy.nvim, not Nix.** Don't hand-edit
  `nvim/.config/nvim/lazy-lock.json`. See `nvim/.config/nvim/README.md` before
  changing the Neovim setup.

## Package pins

- `nixpkgs-azure-cli` is a commit-pinned nixpkgs that deliberately does **not**
  follow `nixpkgs`. Don't add `inputs.nixpkgs.follows` to it.
- `copilotOverlay` overrides `github-copilot-cli`. A version bump must update
  the version **and both** platform hashes (`x86_64-linux` and
  `aarch64-linux`).
- Every other input follows `nixpkgs`. Do the same for new inputs.
- Add new package overrides as overlays in `mkSystem`, so NixOS and Home
  Manager (`useGlobalPkgs = true`) see the same package. Record them in
  `docs/EXAMPLE-VERSION-PINNING.md`.

## Nix gotchas

- The flake only sees files tracked by Git. Run `git add` on a new file before
  evaluating or building. It doesn't need to be committed.
- The NixOS hosts are `x86_64-linux` only, but the checks, formatter and dev
  shell also cover `aarch64-linux`. Per-platform data such as URLs and hashes
  needs entries for both.
- CI runs `deadnix --fail` and `statix`. Remove module arguments (`pkgs`,
  `config`, ...) and `let` bindings you stop using.
- Format Nix with `nixfmt` (the flake's formatter), not `nixpkgs-fmt`.
- `systemd.user.startServices = "suggest"` in the WSL home is intentional. It
  lets the bootstrap configuration activate before any user session exists.
- The username `user3301` and the checkout path `/home/user3301/dotfiles` are
  hard-coded in several files. Don't rename them unless asked; see
  `docs/DEPLOYMENT.md` for every place involved.

## Adding an application config

1. Put the files in `<app>/.config/<app>/`.
2. Link the directory from the matching `home/modules/*.nix` with
   `xdg.configFile."<app>".source = config.lib.file.mkOutOfStoreSymlink ...`.
3. If the app is also used on macOS or Arch, add `<app>` to `STOW_PACKAGES` in
   `Makefile`, and its package to `Brewfile` or `pacman-packages.txt`.
4. Update the module table and Stow package lists in `docs/`.

## Validate before finishing

These commands mirror CI (`.github/workflows/ci.yml`) and need no `sudo`:

```sh
nix fmt <changed .nix files>
nix build --no-link \
  .#checks.x86_64-linux.nix-quality \
  .#checks.x86_64-linux.lua-format \
  .#checks.x86_64-linux.zsh-syntax \
  .#checks.x86_64-linux.bash-syntax
nix eval --raw '.#nixosConfigurations.nixos-wsl.config.system.build.toplevel.drvPath'
# CI doesn't evaluate the native host. Do it when you touch shared or native modules:
nix eval --raw '.#nixosConfigurations.nixos-native.config.system.build.toplevel.drvPath'
```

Check the output for `evaluation warning:` lines as well as the exit code.
`nix develop` provides nixfmt, statix, deadnix, StyLua and nil.

## Conventions

- Commit subjects are imperative and sentence case, with no type prefix, for
  example "Add kubectl and kubectx to dev-tools". The default branch is
  `master`.
- Pin GitHub Actions to a full commit SHA, with the version in a trailing
  comment (`# v7.0.1`).
- `docs/` describes the current setup. When you change behavior, packages,
  modules or pins, update the matching doc in the same change.
