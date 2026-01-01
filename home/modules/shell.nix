{ config, pkgs, lib, ... }:

{
  # Install oh-my-zsh package (not managed by Home Manager's programs.zsh.oh-my-zsh)
  # This allows your .zshrc to have full control
  home.packages = with pkgs; [
    oh-my-zsh
  ];

  # Install oh-my-zsh to the expected location
  home.file.".oh-my-zsh".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh";

  # Symlink .zshrc from dotfiles (this has full control over zsh configuration)
  home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/zsh/.zshrc";

  # Symlink .zshenv
  home.file.".zshenv".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/zsh/.zshenv";
}
