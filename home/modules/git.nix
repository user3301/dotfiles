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
  # Symlinks entire git config directory to include config.local and other files
  xdg.configFile."git".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/git/.config/git";

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
