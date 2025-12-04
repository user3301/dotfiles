{ config, pkgs, lib, ... }:

{
  # Git configuration managed by home-manager
  # Currently using minimal config - git is installed via packages.nix

  # Uncomment and customize to manage git config via home-manager:
  programs.git = {
    enable = true;
    userName = "user3301";
    userEmail = "stan_gai@hotmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = false;

      # Useful aliases
      # inherit aliases from omz
      # alias = {
      #   st = "status";
      #   co = "checkout";
      #   br = "branch";
      #   ci = "commit";
      #   lg = "log --graph --oneline --all";
      # };
    };

    # Git ignore patterns
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".direnv/"
    ];
  };
}
