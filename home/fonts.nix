{ config, pkgs, lib, ... }:

{
  # Font management via home-manager
  # Fonts will be installed to ~/.local/share/fonts (Linux) or ~/Library/Fonts (macOS)

  fonts.fontconfig.enable = true;

 # The Problem
 #
 #  - ✅ WSL2 Ubuntu: Fonts installed to ~/.local/share/fonts (inside WSL filesystem)
 #  - ❌ Windows Terminal: Looks for fonts in Windows font directory (C:\Windows\Fonts)
 #
 #  WSL2 runs in a virtualized Linux environment, so fonts installed in WSL are not automatically
 #   available to Windows applications like Windows Terminal.
  home.packages = with pkgs; [
    # Fonts used in wezterm.lua
    ubuntu-classic        # Ubuntu Mono
    jetbrains-mono        # JetBrains Mono

    # Note: "More Perfect DOS VGA" is not available in nixpkgs
    # I need to manually download it as it is used in my wezterm
    # font config
  ];
}
