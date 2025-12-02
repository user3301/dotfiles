{ config, pkgs, lib, ... }:

let
  # Dynamically get username from environment
  username = builtins.getEnv "USER";
in
{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = username;
  home.homeDirectory = lib.mkDefault "/Users/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    git
  ];

  # Git configuration (optional - can be managed by home-manager)
  # Uncomment and customize if you want home-manager to manage your git config
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your.email@example.com";
  #   extraConfig = {
  #     init.defaultBranch = "main";
  #     core.editor = "nvim";
  #   };
  # };
}
