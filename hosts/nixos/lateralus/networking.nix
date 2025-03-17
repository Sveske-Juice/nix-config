{
  lib,
  config,
  pkgs,
  ...
}: {
  networking.hostName = "lateralus";
  networking.networkmanager.enable = true;
}
