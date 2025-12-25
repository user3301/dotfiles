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
    gcc         # nvim-treesitter depencency

    # Development tools
    fzf
    bat
    yazi

    asdf-vm
    fastfetchMinimal

    # Golang Development
    grpcurl
    pkgs.golangci-lint
    protobuf_33
    protoc-gen-go-grpc
    protoc-gen-go
  ];
}
