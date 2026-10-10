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
    gcc # also used by Neovim's Tree-sitter
    gnumake
    xdg-utils

    # Kubernetes
    kubectl
    kubectx

    # Cloud
    azure-cli

    # Nix development (nil and nixpkgs-fmt are in neovim.nix)
    nix-tree

    # AI
    claude-code
    github-copilot-cli

    # Dev containers
    devcontainer
  ];
}
