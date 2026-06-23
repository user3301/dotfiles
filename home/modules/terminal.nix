{ config, ... }:

{
  # Zellij terminal multiplexer
  programs.zellij = {
    enable = true;
    # Settings managed via existing config file
  };

  # Symlink existing zellij config
  xdg.configFile."zellij".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zellij/.config/zellij";

  # Yazi file manager
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "yy";
  };

  xdg.configFile."yazi".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/yazi/.config/yazi";

  # Fastfetch system info (package managed in dev-tools.nix)
  xdg.configFile."fastfetch".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/fastfetch/.config/fastfetch";
}
