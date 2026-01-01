{
  description = "user3301's' dotfiles for NixOS, NixOS WSL2, and Archlinux";

  inputs = {
    # Nixpkgs - use unstable for latest packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    claude-code.url = "git+https://codeberg.org/MachsteNix/claude-code-nix";

    # Home Manager - for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix - for secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS WSL - for WSL2 support
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin - for macOS support (optional, keeping for your current setup)
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, nixos-wsl, nix-darwin, ... }@inputs:
    let
      # Helper function to generate system configurations
      mkSystem = { system, modules, specialArgs ? {} }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = modules;
          specialArgs = specialArgs // { inherit inputs; };
        };

      # Helper function for standalone Home Manager (Archlinux, etc.)
      mkHome = { system, username, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = modules;
          extraSpecialArgs = { inherit inputs; };
        };

      # Helper function for nix-darwin (macOS)
      mkDarwin = { system, modules }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = modules;
          specialArgs = { inherit inputs; };
        };

      # Common module paths
      homeModulesPath = ./home/modules;
      systemModulesPath = ./systems/modules;
    in
    {
      # NixOS Configurations
      nixosConfigurations = {
        # NixOS WSL2 Configuration
        nixos-wsl = mkSystem {
          system = "x86_64-linux";
          modules = [
            # WSL-specific module
            nixos-wsl.nixosModules.wsl

            # System configuration
            ./systems/wsl/configuration.nix

            # Home Manager integration
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.user3301 = import ./home/nixos-wsl.nix;
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };

        # Native NixOS Configuration
        nixos-native = mkSystem {
          system = "x86_64-linux";
          modules = [
            # System configuration
            ./systems/native/configuration.nix

            # Home Manager integration
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.user3301 = import ./home/nixos-native.nix;
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };
      };

      # Standalone Home Manager Configurations (for Archlinux, etc.)
      homeConfigurations = {
        # Generic Linux configuration (Archlinux, Ubuntu, Fedora, etc.)
        "user@linux" = mkHome {
          system = "x86_64-linux";
          username = "user";
          modules = [
            ./home/archlinux.nix
          ];
        };

        # ARM64 Linux configuration
        "user@linux-arm64" = mkHome {
          system = "aarch64-linux";
          username = "user";
          modules = [
            ./home/archlinux.nix
          ];
        };
      };

      # macOS configurations (keeping your existing setup)
      darwinConfigurations = {
        # macOS Apple Silicon
        "aarch64" = mkDarwin {
          system = "aarch64-darwin";
          modules = [
            ./systems/darwin/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.gaiz = import ./home/darwin.nix;
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };

        # macOS Intel
        "x86_64" = mkDarwin {
          system = "x86_64-darwin";
          modules = [
            ./systems/darwin/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.gaiz = import ./home/darwin.nix;
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };
      };

      # Development shell (optional but useful)
      devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            vim
            nil # Nix LSP
            nixpkgs-fmt
          ];
          shellHook = ''
            echo "Dotfiles development environment"
            echo "Use 'nixos-rebuild' or 'home-manager' commands to apply configurations"
          '';
        }
      );
    };
}
