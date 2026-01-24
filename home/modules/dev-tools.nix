{ pkgs, ... }:

{
  # Development packages
  home.packages = with pkgs; [
    vim

    # Version control
    git
    gh # GitHub CLI
    lazygit

    # Modern CLI tools
    ripgrep
    fd
    bat
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
    pkgs.claude-code
  ];
}
