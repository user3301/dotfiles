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
    gnupg
  ];

  # WSL-specific session variables
  home.sessionVariables = {
    # Add any WSL-specific environment variables
  };

  # Git configuration for WSL
  programs.git = {
    enable = true;
    signing = {
      key = "23B0107B5D3811FB";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "user3301";
        email = "26126682+user3301@users.noreply.github.com";
      };
      core = {
        # Handle Windows line endings
        autocrlf = "input";
      };
    };
  };

  # GPG configuration
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # Home Manager state version
  home.stateVersion = "25.05";
}
