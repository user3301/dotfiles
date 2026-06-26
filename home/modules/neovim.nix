{ config, pkgs, ... }:

{
  # Install neovim and related packages
  home.packages = with pkgs; [
    neovim

    # LSP servers
    lua-language-server
    nil # Nix LSP
    typescript-language-server
    vscode-langservers-extracted # HTML, CSS, JSON, ESLint
    pyright
    rust-analyzer
    gopls
    roslyn-ls # C# LSP (Microsoft.CodeAnalysis.LanguageServer, driven by roslyn.nvim)

    # Formatters
    stylua
    nixpkgs-fmt
    prettier
    black
    rustfmt

    # Tools
    ripgrep
    fd
    tree-sitter
    gcc # for treesitter compilation
    fswatch # backend for Neovim LSP file watching (used by roslyn.nvim)
  ];

  # Symlink your existing nvim config
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";
}
