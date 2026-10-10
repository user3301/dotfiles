{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.packages = [
    # Herdr terminal agent multiplexer (https://herdr.dev)
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Yazi file manager (its `y` cd-on-exit wrapper lives in zsh/.zshrc)
    pkgs.yazi
  ];

  xdg.configFile = {
    # Symlink herdr config so herdr's own writes (onboarding, settings) land in the repo
    "herdr".source = config.lib.dotfiles.link "herdr/.config/herdr";

    "yazi".source = config.lib.dotfiles.link "yazi/.config/yazi";

    # Fastfetch system info (package managed in dev-tools.nix)
    "fastfetch".source = config.lib.dotfiles.link "fastfetch/.config/fastfetch";
  };
}
