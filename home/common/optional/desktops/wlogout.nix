{
  lib,
  config,
  pkgs,
  ...
}:
{
  # Let stylix style it
  programs.wlogout = {
    enable = true;
  };
}
