{ config, pkgs, ... }:

{
  # Git package
  home.packages = with pkgs; [
    git
    gh # GitHub CLI
    lazygit
  ];

  # Git configuration via XDG config symlink
  # This allows sharing the same config with macOS via GNU Stow
  xdg.configFile."git/config".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/git/.config/git/config";

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
