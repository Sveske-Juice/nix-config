{
  lib,
  config,
  pkgs,
  ...
}: {
  networking.hostName = config.hostSpec.hostName;
  networking.networkmanager.enable = true;

  networking.firewall.allowedUDPPorts = [53 67];
}
