{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.hostName = config.hostSpec.hostName;
  networking.networkmanager.enable = true;

  networking.firewall.allowedUDPPorts = [
    5353 # spotify: Google cast + Spotity Connect
  ];
}
