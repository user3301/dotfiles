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

    # This is my IDE.
    neovim

    # Terminal multiplexer
    zellij

    # CLI tools (LazyVim dependencies and utilities)
    fd          # Fast find alternative
    ripgrep     # Fast grep alternative (rg)

    # Development tools
    # TODO:currently 0.18.0 and above is not available in nixpkgs
    # install asdf via home-manager once available
    # asdf-vm     # Version manager for multiple languages

    fzf
    bat
    yazi
  ];
}
