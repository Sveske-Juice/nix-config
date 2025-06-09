{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.alacritty = {
    enable = true;
    settings = { };
  };

  home.sessionVariables = {
    TERM = "alacritty";
  };
}
