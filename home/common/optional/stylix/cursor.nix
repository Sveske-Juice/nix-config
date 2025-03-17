{
  lib,
  config,
  pkgs,
  ...
}: {
  stylix.cursor = {
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
  };
}
