{ pkgs, ... }:

{
  # Development packages
  home.packages = with pkgs; [
    vim

    # Modern CLI tools
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    tree
    grpcurl
    fastfetch

    # Build tools
    gcc
    gnumake
    xdg-utils

    # Nix development
    nil # Nix LSP
    nixpkgs-fmt
    nix-tree

    # AI
    claude-code
    github-copilot-cli
  ];
}
