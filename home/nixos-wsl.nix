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
