# macOS-specific configuration
# This file contains packages and settings that are macOS-only
{ pkgs, ... }:

{
  # Note: Some GUI applications are better installed via Homebrew
  # as they're not available in nixpkgs or work better as native apps
  #
  # For these apps, keep using Brewfile:
  # - wezterm (cask)
  # - visual-studio-code@insiders (cask)
  # - zed (cask)
  # - nikitabobko/tap/aerospace (cask)
  # - font-zed-mono (cask)

  home.packages = with pkgs; [
    # macOS-specific CLI tools can go here
  ];
}
