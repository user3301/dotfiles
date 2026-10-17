# Nix Package Version Pinning

This guide describes the overrides in `flake.nix`. They apply to NixOS only;
macOS and Arch Linux packages come from `Brewfile` and `pacman-packages.txt`.

## Main package set

`nixpkgs` tracks `nixos-26.05` and Home Manager tracks `release-26.05`.
`flake.lock` pins their resolved commits. Updates are explicit:

```sh
nix flake update nixpkgs home-manager
```

This updates the lockfile, not the running system. Rebuild the selected NixOS
configuration afterward.

## Azure CLI: a separate nixpkgs revision

The flake pins `nixpkgs-azure-cli` to
`286615174c6bd765907ef9975d0acdc799c7bf7e`, which provides Azure CLI 2.77.0.
It does not follow the main nixpkgs input. The overlay imports that package set
for the host system and exposes its Azure CLI:

```nix
azureCliOverlay = final: _prev: {
  inherit (import inputs.nixpkgs-azure-cli { inherit (final.stdenv.hostPlatform) system; })
    azure-cli
    ;
};
```

`mkSystem` installs the overlay in `nixpkgs.overlays`. Because integrated Home
Manager uses the global package set, `pkgs.azure-cli` in
`home/modules/dev-tools.nix` resolves to the pinned version.

Inspect the actual package selected by the system:

```sh
nix eval --raw '.#nixosConfigurations.nixos-wsl.pkgs.azure-cli.version'
```

To change it, choose a nixpkgs commit containing the desired package, change
the input URL, and run `nix flake lock`. Updating other inputs does not move
this explicit commit pin.

## Copilot CLI: version and source override

`copilotOverlay` overrides the existing `github-copilot-cli` derivation's
version and source. It currently selects 1.0.98 and platform-specific
`linux-x64` / `linux-arm64` release archives, each with its own hash, while
retaining the nixpkgs packaging logic. The override also supplies the GTK,
WebKitGTK, and related shared libraries required by the bundled webview.

```sh
nix eval --raw '.#nixosConfigurations.nixos-wsl.pkgs.github-copilot-cli.version'
```

When changing this override, update both the version and each supported
platform's archive hash in `flake.nix`. A version edit without matching hashes
is insufficient. Build the package before deploying:

```sh
nix build --no-link '.#nixosConfigurations.nixos-wsl.pkgs.github-copilot-cli'
```

The flake comment links the upstream nixpkgs issue motivating this workaround.
Remove the overlay when the pinned main package set supplies the desired
working package.

## Roslyn: a newer package recipe

`roslynOverlay` supplies `roslyn-ls` 5.12.0-1.26475.2 for the pinned
`roslyn.nvim` plugin, which requires at least 5.12.0-1.26453.19. The main
package set's older server does not meet that requirement.

The overlay fetches the Roslyn recipe from nixpkgs commit
`ca0dc65018ebc2b7669325a31e2519c524866f81` and calls it with the existing
package set. It does not import a second package set or update any flake
inputs. This retains upstream's source build, NuGet dependency lock, and
patch that puts the composition cache in `$XDG_CACHE_HOME/roslyn` (or
`~/.cache/roslyn`) rather than beside the read-only server assembly.

The recipe uses the existing .NET 11 SDK at build time. The server runtime
and the SDK installed for interactive development remain .NET 10.

```sh
nix eval --raw '.#nixosConfigurations.nixos-wsl.pkgs.roslyn-ls.version'
nix build --no-link '.#nixosConfigurations.nixos-wsl.pkgs.roslyn-ls'
```

When updating this pin, update the recipe commit and its source hash together,
review its SDK requirements, and build the package. Remove the overlay when
the main package set provides a compatible server with the needed Nix fixes.

## Claude Code and Herdr

Claude Code comes from `claude-code-nix.overlays.default`. Herdr is installed
directly from `inputs.herdr.packages.<system>.default` in `terminal.nix`.
Both inputs follow the main nixpkgs package set and have their own revisions
recorded in `flake.lock`.

```sh
nix flake update claude-code-nix herdr
```

## Adding another pin

Prefer the existing pattern: add a commit-pinned input when you need the
package and its dependency set from that revision, then add a narrowly scoped
overlay to `mkSystem`. For a source-only override, review whether the current
nixpkgs patches, dependencies, and build steps still apply to the new source.
Do not merely change `version` and assume the package source changed with it.

Keep overrides at the system package-set level so both NixOS and integrated
Home Manager see the same package. Review the lockfile diff to avoid unrelated
upgrades.

```sh
nix flake check
sudo nixos-rebuild build --flake .#nixos-wsl
sudo nixos-rebuild switch --flake .#nixos-wsl
```

Use `.#nixos-native` for the native host. Commit deliberate flake and lockfile
changes together.
