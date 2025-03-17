{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # ./cursor.nix
    ./fonts.nix
  ];

  stylix.enable = true;
  stylix.image = ../../../../wallpapers/wallhaven-p2oowm.jpg;
  stylix.polarity = "dark";
}
