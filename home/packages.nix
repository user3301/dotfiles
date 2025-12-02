{ config, pkgs, lib, ... }:

{
  # All packages to install via home-manager
  home.packages = with pkgs; [
    # Version control
    git

    # Shell
    zsh
    oh-my-zsh

    # Editors
    neovim

    # Add more packages here as you migrate from Brewfile
    # Example:
    # ripgrep
    # fzf
    # bat
    # lazygit
    # yazi
  ];
}
