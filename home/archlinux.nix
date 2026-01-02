{ config, pkgs, inputs, lib, ... }:

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

  # User information - IMPORTANT: Change these before deployment
  home.username = "user3301";
  home.homeDirectory = "/home/user3301";

  # Archlinux-specific configuration
  # Since this is standalone Home Manager (not NixOS), we need to be careful
  # about what services and features we enable

  # Additional packages for Archlinux
  home.packages = with pkgs; [
    # Tools that complement Arch packages
    # Most system packages will be installed via pacman
    # Use Nix for development tools and user applications

    # Example: Nix-specific or bleeding-edge tools
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "user3301";
    userEmail = "26126682+user3301@users.noreply.github.com";
  };

  # Targets for non-NixOS systems
  targets.genericLinux.enable = true;

  # Home Manager state version
  home.stateVersion = "25.05";
}
