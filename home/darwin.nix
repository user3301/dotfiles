{
  config,
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
  ];

  home = {
    # User information
    username = "gaiz";
    homeDirectory = "/Users/gaiz";

    # macOS-specific packages
    packages = with pkgs; [
      # macOS-specific tools
      # Note: GUI apps installed via Homebrew (see Brewfile)
    ];

    # Home Manager state version
    stateVersion = "24.05";
  };

  # Aerospace window manager config
  xdg.configFile."aerospace".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/aerospace/.config/aerospace";

}
