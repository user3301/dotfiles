{ config, pkgs, dotfilesPath, ... }:

{
  home = {
    # Set this to your actual username
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";

    stateVersion = "24.05";

    packages = with pkgs; [
      # Shell & terminal
      zsh
      fzf
      mcfly

      # Editors & dev tools
      neovim
      helix

      # Terminal multiplexers & utilities
      wezterm
      zellij

      # File utilities
      bat
      ripgrep
      fd
      yazi

      # Dev tools
      jq
      lazygit
      asdf

      # Fonts
      jetbrains-mono
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  # Link dotfiles configurations
  xdg.configHome = "${config.home.homeDirectory}/.config";

  # Wezterm configuration
  xdg.configFile."wezterm" = {
    source = "${dotfilesPath}/wezterm/.config/wezterm";
    recursive = true;
  };

  # Neovim configuration
  xdg.configFile."nvim" = {
    source = "${dotfilesPath}/nvim/.config/nvim";
    recursive = true;
  };

  # Helix configuration
  xdg.configFile."helix" = {
    source = "${dotfilesPath}/helix/.config/helix";
    recursive = true;
  };

  # Zellij configuration
  xdg.configFile."zellij" = {
    source = "${dotfilesPath}/zellij/.config/zellij";
    recursive = true;
  };

  # Yazi configuration
  xdg.configFile."yazi" = {
    source = "${dotfilesPath}/yazi/.config/yazi";
    recursive = true;
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    # Source the existing .zshrc from dotfiles
    initExtraBeforeCompInit = ''
      [[ -f ${dotfilesPath}/zsh/.zshrc ]] && source ${dotfilesPath}/zsh/.zshrc
    '';
  };

  # Home manager configuration
  programs.home-manager.enable = true;
}
