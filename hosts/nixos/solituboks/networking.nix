{
  lib,
  config,
  pkgs,
  ...
}: {
  networking.hostName = config.hostSpec.hostName;
  networking.networkmanager.enable = true;
}
