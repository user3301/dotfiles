{
  config,
  pkgs,
  ...
}:

{
  # Symlink i3 config
  xdg.configFile."i3".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/i3/.config/i3";

  # Symlink polybar config
  xdg.configFile."polybar".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/polybar/.config/polybar";

  # Symlink picom config
  xdg.configFile."picom".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/picom/.config/picom";

  # Symlink rofi config
  xdg.configFile."rofi".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/rofi/.config/rofi";

  # Desktop packages
  home.packages = with pkgs; [
    # Window manager utilities
    polybar
    picom
    rofi

    # Utilities
    feh              # Wallpaper setter
    maim             # Screenshot tool
    xclip            # Clipboard
    dunst            # Notifications
    pavucontrol      # Audio control GUI
    networkmanagerapplet  # Wifi tray applet
    xdotool          # X11 automation
    xorg.xrandr      # Display management

    # Theming
    papirus-icon-theme
    lxappearance     # GTK theme switcher
  ];
}
