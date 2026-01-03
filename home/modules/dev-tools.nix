{ config, pkgs, lib, ... }:

{
  # Development packages
  home.packages = with pkgs; [
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

  # Git configuration
  programs.git = {
    enable = true;
    # User will configure name/email in their local .gitconfig or via system config
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
