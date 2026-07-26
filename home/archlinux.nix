{ pkgs, ... }:

{
  # Import common modules
  imports = [
    ./modules/common.nix
    ./modules/shell.nix
    ./modules/dev-tools.nix
    ./modules/git.nix
    ./modules/neovim.nix
    ./modules/terminal.nix
    ./modules/wezterm.nix
    ./modules/languages.nix
  ];

  # Archlinux-specific configuration
  # Since this is standalone Home Manager (not NixOS), we need to be careful
  # about what services and features we enable

  home = {
    # User information - IMPORTANT: Change these before deployment
    username = "user3301";
    homeDirectory = "/home/user3301";

    # Additional packages for Archlinux
    packages = with pkgs; [
      # Tools that complement Arch packages
      # Most system packages will be installed via pacman
      # Use Nix for development tools and user applications

      # Example: Nix-specific or bleeding-edge tools
    ];

    # Home Manager state version
    stateVersion = "25.05";
  };

  # Targets for non-NixOS systems
  targets.genericLinux.enable = true;
}
