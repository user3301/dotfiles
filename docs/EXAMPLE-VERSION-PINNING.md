# How to Pin Specific Package Versions in Nix

This guide shows how to use different versions of packages from different nixpkgs commits.

## Scenario

You want:
- **Package A** (e.g., neovim 0.11.5) from nixpkgs commit `abc123`
- **Package B** (e.g., ripgrep 14.0.0) from nixpkgs commit `def456`
- **Everything else** from the latest unstable

## Step 1: Find the Right Commits

### Method 1: Using nixpkgs commit history

1. Go to https://github.com/NixOS/nixpkgs/commits/master
2. Search for commits that updated your package
3. Or use GitHub search: `repo:NixOS/nixpkgs neovim 0.11.5`

### Method 2: Using search.nixos.org

1. Visit https://search.nixos.org/packages
2. Search for your package (e.g., "neovim")
3. Select different channels/versions to see what's available
4. Note the channel name (e.g., `nixos-24.05`, `nixpkgs-unstable`)

### Method 3: Using Nix CLI to check versions

```bash
# Check version in current unstable
nix eval nixpkgs#neovim.version

# Check version at a specific commit
nix eval github:NixOS/nixpkgs/abc123def456#neovim.version

# Search for a package
nix search nixpkgs#neovim
```

## Step 2: Update flake.nix

Add additional nixpkgs inputs for each version you need:

```nix
{
  description = "Gaiz's dotfiles - Nix flake configuration";

  inputs = {
    # Main nixpkgs (latest unstable)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Pinned version for Package A (neovim 0.11.5)
    # Replace 'abc123def456' with actual commit hash
    nixpkgs-neovim.url = "github:NixOS/nixpkgs/abc123def456";

    # Pinned version for Package B (ripgrep 14.0.0)
    # Replace 'def789ghi012' with actual commit hash
    nixpkgs-ripgrep.url = "github:NixOS/nixpkgs/def789ghi012";

    # You can also use branch names or tags
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-neovim, nixpkgs-ripgrep, nix-darwin, home-manager, ... }:
    let
      username = builtins.getEnv "USER";

      # Helper to create package sets for different nixpkgs
      mkPkgs = system: nixpkgsInput: import nixpkgsInput {
        inherit system;
        config.allowUnfree = true;
      };

      mkSystem = system:
        let
          pkgs = mkPkgs system nixpkgs;
          pkgs-neovim = mkPkgs system nixpkgs-neovim;
          pkgs-ripgrep = mkPkgs system nixpkgs-ripgrep;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            home-manager.darwinModules.home-manager
            {
              nix.settings.experimental-features = "nix-command flakes";
              system.stateVersion = 5;

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home.nix;

              # Pass the custom package sets to home-manager
              home-manager.extraSpecialArgs = {
                inherit pkgs-neovim pkgs-ripgrep;
              };
            }
          ];
        };

      mkHome = system:
        let
          pkgs = mkPkgs system nixpkgs;
          pkgs-neovim = mkPkgs system nixpkgs-neovim;
          pkgs-ripgrep = mkPkgs system nixpkgs-ripgrep;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
          ];
          # Pass the custom package sets to home.nix
          extraSpecialArgs = {
            inherit pkgs-neovim pkgs-ripgrep;
          };
        };
    in
    {
      darwinConfigurations = {
        "aarch64" = mkSystem "aarch64-darwin";
        "x86_64" = mkSystem "x86_64-darwin";
      };

      homeConfigurations = {
        "${username}-aarch64" = mkHome "aarch64-darwin";
        "${username}-x86_64" = mkHome "x86_64-darwin";
      };
    };
}
```

## Step 3: Update home.nix

Use the pinned packages in your home configuration:

```nix
{ config, pkgs, lib, pkgs-neovim ? pkgs, pkgs-ripgrep ? pkgs, ... }:

let
  username = builtins.getEnv "USER";
in
{
  home.username = username;
  home.homeDirectory = lib.mkDefault "/Users/${username}";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = [
    # Use default nixpkgs
    pkgs.git
    pkgs.fzf
    pkgs.bat

    # Use pinned neovim from specific commit
    pkgs-neovim.neovim

    # Use pinned ripgrep from specific commit
    pkgs-ripgrep.ripgrep
  ];
}
```

## Step 4: Lock and Build

```bash
# Generate/update flake.lock
nix flake lock

# Check what versions you'll get
nix eval .#homeConfigurations.${USER}-aarch64.config.home.packages.0.version

# Build and activate
darwin-rebuild switch --flake .#aarch64
# OR
home-manager switch --flake .#$USER-aarch64
```

## Alternative: Using Overlays (Advanced)

If you prefer, you can use overlays to override package versions:

```nix
# In home.nix
{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    # Override neovim to a specific version
    (final: prev: {
      neovim = prev.neovim.overrideAttrs (oldAttrs: rec {
        version = "0.11.5";
        src = prev.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          rev = "v${version}";
          hash = "sha256-..."; # Use nix-prefetch-url to get this
        };
      });
    })
  ];

  home.packages = with pkgs; [
    neovim  # Will use overridden version
    git
  ];
}
```

## Finding Commit Hashes

### Quick method using Nix:

```bash
# Find commits for a specific package version
nix-locate --at-root --top-level --whole-name "bin/nvim" | grep "neovim-0.11"

# Or check nixpkgs history
git clone https://github.com/NixOS/nixpkgs --depth 1000
cd nixpkgs
git log --all --grep="neovim.*0.11.5" --oneline
```

### Using nixpkgs-review:

```bash
# Search nixpkgs history
nix run nixpkgs#gh -- search commits --repo=NixOS/nixpkgs "neovim 0.11.5"
```

## Summary

**For multiple package versions:**

1. Add each nixpkgs input with desired commit/branch:
   ```nix
   nixpkgs-packageA.url = "github:NixOS/nixpkgs/<commit>";
   nixpkgs-packageB.url = "github:NixOS/nixpkgs/<commit>";
   ```

2. Create package sets for each:
   ```nix
   pkgs-packageA = mkPkgs system nixpkgs-packageA;
   ```

3. Pass them to home.nix:
   ```nix
   extraSpecialArgs = { inherit pkgs-packageA pkgs-packageB; };
   ```

4. Use in home.nix:
   ```nix
   { pkgs, pkgs-packageA, pkgs-packageB, ... }:
   home.packages = [
     pkgs-packageA.packageA
     pkgs-packageB.packageB
   ];
   ```

This gives you complete control over each package's version!
