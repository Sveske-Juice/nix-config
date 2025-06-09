{
  pkgs,
  config,
  hostSpec,
  ...
}:
{
  imports = [
    # Required
    ../common/core

    ./sops.nix
  ];

  home.username = hostSpec.username;
  home.homeDirectory = hostSpec.home;

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.stateVersion = "24.11";
}
