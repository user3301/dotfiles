{ config, pkgs, lib, ... }:

{
  # Helix editor
  programs.helix = {
    enable = true;

    # Additional language servers for Helix
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil
      nodePackages.typescript-language-server
      pyright
      rust-analyzer
      gopls

      # Formatters
      stylua
      nixpkgs-fmt
      nodePackages.prettier
      black
      rustfmt
    ];
  };

  # Symlink existing helix config
  xdg.configFile."helix".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/helix/.config/helix";
}
