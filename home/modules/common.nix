{ config, pkgs, lib, ... }:

{
  # Common configuration shared across all platforms

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # XDG Base Directory specification
  xdg.enable = true;

  # Basic user information (override in platform-specific configs)
  home.stateVersion = "25.05"; # Update to match your NixOS version

  # Allow unfree packages(eg: Claude-code, Copilot)
  nixpkgs.config.allowUnfree = true;

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    DOTFILES = "${config.home.homeDirectory}/dotfiles";
  };

  # Basic packages that should be available everywhere
  home.packages = with pkgs; [
    # Archive tools
    zip
    unzip

    # Misc utilities
    wget
    curl
  ];
}
