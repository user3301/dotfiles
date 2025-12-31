{
  description = "user3301's dotfiles - Nix flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    copilot-cli.url = "github:scarisey/copilot-cli-flake";
    claude-code.url = "git+https://codeberg.org/MachsteNix/claude-code-nix";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, copilot-cli, ... }:
    let
      # Helper function to create Darwin configurations for different systems
      mkSystem = system: username: nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          home-manager.darwinModules.home-manager
          {
            # Nix settings
            nix.settings.experimental-features = "nix-command flakes";

            # macOS system settings
            system.stateVersion = 5;

            # Home-manager configuration
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home;
          }
        ];
      };
      # Helper function to create home-manager configurations
      mkHome = system: username: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home
        ];
        extraSpecialArgs = {
          inherit username;
          dotfilesPath = toString ./.;
        };
      };

      # Helper to create configs for a specific user
      mkUserConfigs = username: {
        # macOS configurations
        "${username}-aarch64-darwin" = mkHome "aarch64-darwin" username;
        "${username}-x86_64-darwin" = mkHome "x86_64-darwin" username;

        # Linux configurations
        "${username}-x86_64-linux" = mkHome "x86_64-linux" username;
        "${username}-aarch64-linux" = mkHome "aarch64-linux" username;
      };
    in
    {
      # nix-darwin configurations for different architectures
      darwinConfigurations = {
        # These use the actual username from environment at build time
        "aarch64" = mkSystem "aarch64-darwin" (builtins.getEnv "USER");
        "x86_64" = mkSystem "x86_64-darwin" (builtins.getEnv "USER");
      };

      # Standalone home-manager configurations
      # Create configs for common usernames to avoid getEnv issues
      homeConfigurations =
        (mkUserConfigs (builtins.getEnv "USER")) //
        (mkUserConfigs "user3301");

      # NixOS configurations for NixOS and WSL2 (x86_64 and aarch64)
      nixosConfigurations = {
        # a minimal NixOS system that uses home-manager for the user
        "nixos-x86_64" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ({
              users.users.${builtins.getEnv "USER"} = {
                isNormalUser = true;
                home = "/home/${builtins.getEnv "USER"}";
              };
              # Point home-manager to the existing ./home module
              home-manager.users.${builtins.getEnv "USER"} = import ./home;
            })
          ];
        };

        "nixos-aarch64" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ({
              users.users.${builtins.getEnv "USER"} = {
                isNormalUser = true;
                home = "/home/${builtins.getEnv "USER"}";
              };
              home-manager.users.${builtins.getEnv "USER"} = import ./home;
            })
          ];
        };
      };

      packages.x86_64-linux.default = copilot-cli.packages.x86_64-linux.default;
    };
}
