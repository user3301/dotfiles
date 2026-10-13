{ config, pkgs, ... }:

{
  # gopls and rust-analyzer come from neovim.nix; SDKs come from languages.nix.
  home.packages = with pkgs; [
    helix
    csharp-ls
    powershell-editor-services
  ];

  xdg.configFile."helix".source = config.lib.dotfiles.link "helix/.config/helix";
}
