{ config, ... }:

{
  # Wezterm terminal emulator
  # Wezterm is installed in home/nixos-native.nix.
  # Not used on WSL (terminal emulator runs on the Windows host).
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wezterm/.config/wezterm";
}
