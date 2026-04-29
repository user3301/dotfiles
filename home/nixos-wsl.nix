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
    ./modules/editors.nix
    ./modules/languages.nix
  ];

  # User information
  home.username = "user3301";
  home.homeDirectory = "/home/user3301";

  # Platform-specific packages for WSL2
  home.packages = with pkgs; [
    # WSL-specific tools
    wezterm
  ];

  # WSL-specific session variables
  home.sessionVariables = {
    # Add any WSL-specific environment variables
  };

  # Home Manager state version
  home.stateVersion = "25.05";
}
