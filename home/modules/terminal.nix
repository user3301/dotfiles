{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Zellij terminal multiplexer
  programs.zellij = {
    enable = true;
    # Settings managed via existing config file
  };

  # Herdr terminal agent multiplexer (https://herdr.dev)
  home.packages = [
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Symlink herdr config so herdr's own writes (onboarding, settings) land in the repo
  xdg.configFile."herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/herdr/.config/herdr";

  # Symlink existing zellij config
  xdg.configFile."zellij".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zellij/.config/zellij";

  # Yazi file manager
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "yy";
  };

  xdg.configFile."yazi".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/yazi/.config/yazi";

  # Fastfetch system info (package managed in dev-tools.nix)
  xdg.configFile."fastfetch".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/fastfetch/.config/fastfetch";
}
