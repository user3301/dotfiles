{ config, pkgs, lib, ... }:

{
  # Git configuration managed by home-manager
  # Currently using minimal config - git is installed via packages.nix

  # Git configuration via home-manager
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "user3301";
        email = "stan_gai@hotmail.com";
      };
      init.defaultBranch = "master";
      core.editor = "nvim";
      pull.rebase = false;
    };

    # Git ignore patterns
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".direnv/"
      ".tool-versions"
    ];
  };
}
