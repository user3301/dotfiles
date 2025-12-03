{ config, pkgs, lib, ... }:

{
  # Git configuration managed by home-manager
  # Currently using minimal config - git is installed via packages.nix

  # Uncomment and customize to manage git config via home-manager:
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your.email@example.com";
  #
  #   extraConfig = {
  #     init.defaultBranch = "main";
  #     core.editor = "nvim";
  #     pull.rebase = false;
  #
  #     # Useful aliases
  #     alias = {
  #       st = "status";
  #       co = "checkout";
  #       br = "branch";
  #       ci = "commit";
  #       lg = "log --graph --oneline --all";
  #     };
  #   };
  #
  #   # Git ignore patterns
  #   ignores = [
  #     ".DS_Store"
  #     "*.swp"
  #     "*.swo"
  #     "*~"
  #     ".direnv/"
  #   ];
  # };
}
