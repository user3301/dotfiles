{
  description = "user3301's' dotfiles for NixOS, NixOS WSL2, and Archlinux";

  inputs = {
    # Nixpkgs - stable release
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Herdr - terminal agent multiplexer (https://herdr.dev)
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager - for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-wsl,
      nix-darwin,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      claudeOverlay = inputs.claude-code-nix.overlays.default;

      # nixpkgs lags upstream copilot-cli releases; bump to the latest GitHub
      # release, using the platform tarballs since the universal one no longer
      # runs unpatched (see nixpkgs#534884 — drop once it lands)
      copilotOverlay = final: prev: {
        github-copilot-cli = prev.github-copilot-cli.overrideAttrs (
          finalAttrs: _:
          let
            platform =
              {
                "x86_64-linux" = "linux-x64";
                "aarch64-linux" = "linux-arm64";
                "x86_64-darwin" = "darwin-x64";
                "aarch64-darwin" = "darwin-arm64";
              }
              .${prev.stdenv.hostPlatform.system};
          in
          {
            version = "1.0.70";
            src = final.fetchurl {
              url = "https://github.com/github/copilot-cli/releases/download/v${finalAttrs.version}/github-copilot-${finalAttrs.version}-${platform}.tgz";
              hash =
                {
                  "x86_64-linux" = "sha256-z70Rb+FZviiaut8sK/GKJairCe7KVKCR1AJeHLzaRwk=";
                  "aarch64-linux" = "sha256-saIHbLOlh+uivG9HjONeU/IKNNDWm0GAdDmzMC3191o=";
                  "x86_64-darwin" = "sha256-biISO2sXX+HWeGo+4vXRu3M9BN839sFBN0McAcPBWNI=";
                  "aarch64-darwin" = "sha256-Tr+isxFUmWQgQX3ivglJ7x9ONa8JQ9ZVFUdNWuPCKxE=";
                }
                .${prev.stdenv.hostPlatform.system};
            };
          }
        );
      };

      # Helper function to generate system configurations
      mkSystem =
        {
          system,
          modules,
          specialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = modules ++ [
            {
              nixpkgs.overlays = [
                claudeOverlay
                copilotOverlay
              ];
            }
          ];
          specialArgs = specialArgs // {
            inherit inputs;
          };
        };

      # Helper function for standalone Home Manager (Archlinux, etc.)
      mkHome =
        {
          system,
          modules,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              claudeOverlay
              copilotOverlay
            ];
          };
          inherit modules;
          extraSpecialArgs = { inherit inputs; };
        };

      # Helper function for nix-darwin (macOS)
      mkDarwin =
        { system, modules }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          inherit modules;
          specialArgs = { inherit inputs; };
        };

      wslSystemModules = [
        nixos-wsl.nixosModules.wsl
        ./systems/wsl/configuration.nix
      ];

    in
    {
      # NixOS Configurations
      nixosConfigurations = {
        # Minimal first-stage configuration used by the WSL bootstrap app.
        nixos-wsl-bootstrap = mkSystem {
          system = "x86_64-linux";
          modules = wslSystemModules;
        };

        # NixOS WSL2 Configuration
        nixos-wsl = mkSystem {
          system = "x86_64-linux";
          modules = wslSystemModules ++ [
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
          modules = [
            ./home/archlinux.nix
          ];
        };

        # ARM64 Linux configuration
        "user@linux-arm64" = mkHome {
          system = "aarch64-linux";
          modules = [
            ./home/archlinux.nix
          ];
        };
      };

      packages.x86_64-linux.bootstrap-wsl =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.writeShellApplication {
          name = "bootstrap-nixos-wsl";
          runtimeInputs = with pkgs; [
            coreutils
            git
            gnugrep
          ];
          text = builtins.readFile ./scripts/bootstrap-nixos-wsl.sh;
        };

      apps.x86_64-linux.bootstrap-wsl = {
        type = "app";
        program = "${self.packages.x86_64-linux.bootstrap-wsl}/bin/bootstrap-nixos-wsl";
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

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          nix-quality =
            pkgs.runCommand "nix-quality"
              {
                nativeBuildInputs = with pkgs; [
                  deadnix
                  findutils
                  nixfmt
                  statix
                ];
              }
              ''
                find ${self} -type f -name '*.nix' -print0 | xargs -0 nixfmt --check
                statix check ${self}
                deadnix --fail ${self}
                touch "$out"
              '';

          lua-format =
            pkgs.runCommand "lua-format"
              {
                nativeBuildInputs = [ pkgs.stylua ];
              }
              ''
                stylua \
                  --check \
                  --config-path ${self}/nvim/.config/nvim/stylua.toml \
                  ${self}/nvim/.config/nvim \
                  ${self}/wezterm/.config/wezterm
                touch "$out"
              '';

          zsh-syntax =
            pkgs.runCommand "zsh-syntax"
              {
                nativeBuildInputs = [ pkgs.zsh ];
              }
              ''
                zsh -n ${self}/zsh/.zshenv
                zsh -n ${self}/zsh/.zshrc
                touch "$out"
              '';
        }
      );

      # Development shell (optional but useful)
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              deadnix
              git
              nil # Nix LSP
              nixfmt
              statix
              stylua
              vim
              zsh
            ];
            shellHook = ''
              echo "Dotfiles development environment"
              echo "Use 'nixos-rebuild' or 'home-manager' commands to apply configurations"
            '';
          };
        }
      );
    };
}
