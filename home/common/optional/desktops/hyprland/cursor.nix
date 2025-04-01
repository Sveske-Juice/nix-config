{
  lib,
  config,
  pkgs,
  ...
}: {
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
  };
}
