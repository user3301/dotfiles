{ config, pkgs, ... }:

{
  home = {
    # Install oh-my-zsh package (not managed by Home Manager's programs.zsh.oh-my-zsh)
    # This allows your .zshrc to have full control
    packages = with pkgs; [
      oh-my-zsh
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
    };
  };

  # Bash configuration (fallback)
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };
}
