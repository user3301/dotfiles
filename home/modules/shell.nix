{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      # Install oh-my-zsh package (not managed by Home Manager's programs.zsh.oh-my-zsh)
      # This allows your .zshrc to have full control
      oh-my-zsh

      # Completions for the bash fallback (programs.bash is off, see below)
      bash-completion

      # Shell integrations wired up in zsh/.zshrc and bash/.bashrc
      mcfly
      zoxide
    ];

    file = {
      # Install oh-my-zsh to the expected location
      ".oh-my-zsh".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh";

      # Symlink .zshrc from dotfiles (this has full control over zsh configuration)
      ".zshrc".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zsh/.zshrc";

      # Symlink .zshenv
      ".zshenv".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zsh/.zshenv";

      # Bash fallback. programs.bash stays disabled so these stay plain symlinks
      # into the repo, which keeps them usable via GNU Stow on non-Nix machines.
      ".bashrc".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/bash/.bashrc";

      ".bash_profile".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/bash/.bash_profile";
    };
  };
}
