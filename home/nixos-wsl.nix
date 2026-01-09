{ pkgs, ... }:

{
  # Import common modules
  imports = [
    ./modules/common.nix
    ./modules/shell.nix
    ./modules/dev-tools.nix
    ./modules/neovim.nix
    ./modules/terminal.nix
    ./modules/editors.nix
    ./modules/secrets.nix
    ./modules/languages.nix
  ];

  # User information
  home.username = "user3301";
  home.homeDirectory = "/home/user3301";

  # Platform-specific packages for WSL2
  home.packages = with pkgs; [
    # WSL-specific tools
  ];

  # WSL-specific session variables
  home.sessionVariables = {
    # Add any WSL-specific environment variables
  };

  # Git configuration for WSL
  programs.git = {
    enable = true;
    userName = "user3301";
    userEmail = "26126682+user3301@users.noreply.github.com";
    extraConfig = {
      core = {
        # Handle Windows line endings
        autocrlf = "input";
      };
    };
  };

  # Home Manager state version
  home.stateVersion = "25.05";
}
