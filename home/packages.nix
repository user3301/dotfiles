{ config, pkgs, lib, ... }:

{
  # All packages to install via home-manager
  home.packages = with pkgs; [
    # Version control
    git
    lazygit

    # Shell
    zsh
    oh-my-zsh

    # Editors
    neovim

    # Terminal
    wezterm

    # Terminal multiplexer
    zellij

    # CLI tools (LazyVim dependencies and utilities)
    fd          # Fast find alternative
    ripgrep     # Fast grep alternative (rg)

    # Add more packages here as you migrate from Brewfile
    # Example:
    # fzf
    # bat
    # yazi
  ];
}
