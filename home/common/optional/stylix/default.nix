{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./fonts.nix ];

  stylix.enable = true;
  stylix.image = ../../../../wallpapers/wallhaven-l8x1pr.jpg;
  stylix.polarity = "dark";
}
