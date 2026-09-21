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
version and source. It currently selects 1.0.70 and platform-specific
`linux-x64` / `linux-arm64` release archives, each with its own hash, while
retaining the nixpkgs packaging logic.

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
