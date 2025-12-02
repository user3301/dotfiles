{ config, pkgs, lib, ... }:

{
  # All packages to install via home-manager
  home.packages = with pkgs; [
    # Version control
    git

    # Shell
    zsh

    # Add more packages here as you migrate from Brewfile
    # Example:
    # neovim
    # ripgrep
    # fzf
    # bat
    # lazygit
    # yazi
  ];
}
