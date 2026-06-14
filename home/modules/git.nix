{ config, pkgs, ... }:

{
  # Git package
  home.packages = with pkgs; [
    git
    gh # GitHub CLI
    lazygit
    delta # syntax-highlighting pager for git diffs
  ];

  # GPG
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  # Git configuration via XDG config symlink
  # This allows sharing the same config with macOS via GNU Stow
  # Symlinks entire git config directory to include config.local and other files
  xdg.configFile."git".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/git/.config/git";

  # Lazygit configuration via XDG config symlink (delta paging, etc.)
  # Symlinked so it can also be managed with GNU Stow on non-NixOS distros
  xdg.configFile."lazygit".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/lazygit/.config/lazygit";

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
