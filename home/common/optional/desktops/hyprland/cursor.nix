{
  lib,
  config,
  pkgs,
  ...
}: {
  home.pointerCursor = {
    x11.enable = true;
    gtk.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
  };
}
