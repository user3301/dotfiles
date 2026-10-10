{ config, pkgs, ... }:

{
  # Neovim's language servers, formatters and tools. Neovim itself is a system
  # package (systems/common.nix); ripgrep, fd and gcc come from dev-tools.nix.
  home.packages = with pkgs; [
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
    tree-sitter
    fswatch # backend for Neovim LSP file watching (used by roslyn.nvim)
  ];

  # Symlink your existing nvim config
  xdg.configFile."nvim".source = config.lib.dotfiles.link "nvim/.config/nvim";
}
