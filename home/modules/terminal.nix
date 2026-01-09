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

  # Wezterm terminal emulator
  # Note: Wezterm is installed via Homebrew on macOS, via Nix on Linux
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wezterm/.config/wezterm";

  # Yazi file manager
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."yazi".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/yazi/.config/yazi";
}
