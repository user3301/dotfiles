{ config, pkgs, lib, username, ... }:

{
  # Import modular configurations
  imports = [
    ./packages.nix
    ./git.nix
    ./shell.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then lib.mkDefault "/Users/${username}"
    else lib.mkDefault "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
