{
  description = "Reproducible dotfiles configuration with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkHomeConfiguration = system: username:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./nix/home.nix ];
          extraSpecialArgs = {
            dotfilesPath = toString ./.;
            inherit system username;
          };
        };
    in
    {
      # Home configurations for different users/systems
      homeConfigurations = {
        # Default configuration using current user
        "${builtins.getEnv "USER"}" = mkHomeConfiguration
          (if builtins.pathExists /System/Library/CoreServices/SystemVersion.plist
           then if builtins.currentSystem == "aarch64-darwin" then "aarch64-darwin" else "x86_64-darwin"
           else builtins.currentSystem)
          (builtins.getEnv "USER");
      };

      # Development shells for each system
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              home-manager
              nix
              git
            ];
            shellHook = ''
              echo "Dotfiles development shell loaded"
              echo "Run 'home-manager switch --flake .#' to apply configuration"
            '';
          };
        }
      );
    };
}
