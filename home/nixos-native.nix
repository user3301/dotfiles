{
  pkgs,
  ...
}:

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
    ./modules/desktop.nix
  ];

  home = {
    # User information
    username = "user3301";
    homeDirectory = "/home/user3301";

    # Platform-specific packages for native NixOS
    packages = with pkgs; [
      gnupg
      # GUI applications
      wezterm
      firefox
      # Add more GUI apps as needed
    ];

    # Home Manager state version
    stateVersion = "25.11";
  };
}
