{ config, pkgs, lib, ... }:

{
  # Install neovim and related packages
  home.packages = with pkgs; [
    neovim

    # LSP servers
    lua-language-server
    nil # Nix LSP
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # HTML, CSS, JSON, ESLint
    pyright
    rust-analyzer
    gopls

    # Formatters
    stylua
    nixpkgs-fmt
    nodePackages.prettier
    black
    rustfmt

    # Tools
    ripgrep
    fd
    tree-sitter
    gcc # for treesitter compilation
  ];

  # Symlink your existing nvim config
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";
}
