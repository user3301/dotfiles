{ config, pkgs, lib, ... }:

{
  # Font management via home-manager
  # Fonts will be installed to ~/.local/share/fonts (Linux) or ~/Library/Fonts (macOS)

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Fonts used in wezterm.lua
    ubuntu_font_family    # Ubuntu Mono
    jetbrains-mono        # JetBrains Mono

    # Note: "More Perfect DOS VGA" is not available in nixpkgs
    # I need to manually download it as it is used in my wezterm
    # font config
  ];
}
