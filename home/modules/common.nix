{ config, pkgs, ... }:

{
  # Common configuration shared by the NixOS homes
  imports = [
    ./shell.nix
    ./dev-tools.nix
    ./git.nix
    ./neovim.nix
    ./terminal.nix
    ./languages.nix
  ];

  # Link a path in the mutable dotfiles checkout, so edits apply without a
  # rebuild. Usage: config.lib.dotfiles.link "nvim/.config/nvim"
  lib.dotfiles.link =
    path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # XDG Base Directory specification
  xdg.enable = true;

  # No home.sessionVariables: Home Manager's shell modules are off, so zsh never
  # reads them. Shell environment variables go in the zsh/bash startup files.

  # Archive tools. wget and curl are system packages (systems/common.nix).
  home.packages = with pkgs; [
    zip
    unzip
  ];
}
