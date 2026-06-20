{ config, ... }:

{
  # Wezterm terminal emulator
  # Note: Wezterm is installed via Homebrew on macOS, via Nix on Linux
  # Not used on WSL (terminal emulator runs on the Windows host).
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wezterm/.config/wezterm";
}
