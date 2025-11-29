{
  description = "Reproducible dotfiles configuration with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        homeManagerModule = ./nix/home.nix;
      in
      {
        homeConfigurations."${builtins.getEnv "USER"}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ homeManagerModule ];
          extraSpecialArgs = {
            dotfilesPath = toString ./.;
          };
        };

        devShells.default = pkgs.mkShell {
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
}
