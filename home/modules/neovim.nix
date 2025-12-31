{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Install additional packages needed by your nvim config
    extraPackages = with pkgs; [
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

    # Additional Lua configuration
    extraLuaConfig = ''
      -- Nix-managed neovim is running
      -- Your actual config will be loaded from ~/.config/nvim/init.lua
    '';
  };

  # Symlink your existing nvim config
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";
}
