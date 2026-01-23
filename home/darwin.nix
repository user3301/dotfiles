{ config, pkgs, inputs, lib, ... }:

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

  # Home Manager state version
  home.stateVersion = "24.05";
}
