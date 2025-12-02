{
  description = "Gaiz's dotfiles - Nix flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      # Dynamically get username from environment
      username = builtins.getEnv "USER";

      # Helper function to create configurations for different systems
      mkSystem = system: nix-darwin.lib.darwinSystem {
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

      mkHome = system: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home
        ];
      };
    in
    {
      # nix-darwin configurations for different architectures
      darwinConfigurations = {
        "aarch64" = mkSystem "aarch64-darwin";  # Apple Silicon
        "x86_64" = mkSystem "x86_64-darwin";     # Intel Mac
      };

      # Standalone home-manager configurations
      homeConfigurations = {
        # macOS configurations
        "${username}-aarch64-darwin" = mkHome "aarch64-darwin";  # Apple Silicon Mac
        "${username}-x86_64-darwin" = mkHome "x86_64-darwin";    # Intel Mac

        # Linux configurations
        "${username}-x86_64-linux" = mkHome "x86_64-linux";      # x86_64 Linux (Ubuntu, etc.)
        "${username}-aarch64-linux" = mkHome "aarch64-linux";    # ARM64 Linux (Raspberry Pi, etc.)
      };
    };
}
