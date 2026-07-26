{ pkgs, ... }:

{
  # Import common modules
  imports = [
    ./modules/common.nix
    ./modules/shell.nix
    ./modules/dev-tools.nix
    ./modules/git.nix
    ./modules/neovim.nix
    ./modules/terminal.nix
    ./modules/languages.nix
  ];

  home = {
    # User information
    username = "user3301";
    homeDirectory = "/home/user3301";

    # Platform-specific packages for WSL2
    packages = with pkgs; [
      # WSL-specific tools
      powershell
    ];

    # WSL-specific session variables
    sessionVariables = {
      # Add any WSL-specific environment variables
    };

    # Home Manager state version
    stateVersion = "25.05";
  };
}
