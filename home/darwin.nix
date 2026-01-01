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
  ];

  # User information
  home.username = "gaiz";
  home.homeDirectory = "/Users/gaiz";

  # macOS-specific packages
  home.packages = with pkgs; [
    # macOS-specific tools
    # Note: GUI apps installed via Homebrew (see Brewfile)
  ];

  # Aerospace window manager config
  xdg.configFile."aerospace".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/aerospace/.config/aerospace";

  # Git configuration
  programs.git = {
    enable = true;
    userName = "gaiz";
    userEmail = "26126682+user3301@users.noreply.github.com";
  };

  # Home Manager state version
  home.stateVersion = "24.05";
}
