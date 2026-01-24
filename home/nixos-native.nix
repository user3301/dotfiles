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

  # User information
  home.username = "user3301";
  home.homeDirectory = "/home/user3301";

  # Platform-specific packages for native NixOS
  home.packages = with pkgs; [
    # GUI applications
    wezterm
    firefox
    # Add more GUI apps as needed
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "user3301";
    userEmail = "26126682+user3301@users.noreply.github.com";
  };

  # Home Manager state version
  home.stateVersion = "25.11";
}
