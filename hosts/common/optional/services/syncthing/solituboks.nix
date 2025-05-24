{
  config,
  lib,
  ...
}: let
  guiPort = 8384;
  idFiles = lib.attrNames (builtins.readDir ./devices);
  deviceIds = builtins.listToAttrs (map (file: import (./devices + "/${file}")) idFiles);
in {
  # sops.secrets."syncthing/certpem" = {
  #   owner = config.services.syncthing.user;
  #   group = config.services.syncthing.group;
  # };
  #
  # sops.secrets."syncthing/keypem" = {
  #   owner = config.services.syncthing.user;
  #   group = config.services.syncthing.group;
  # };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "127.0.0.1:${toString guiPort}";
    overrideDevices = true;
    overrideFolders = true;
    # Wait for: https://github.com/NixOS/nixpkgs/issues/244059
    # cert = config.sops.secrets."syncthing/certpem".path;
    # key = config.sops.secrets."syncthing/keypem".path;
    settings = {
      devices = builtins.trace deviceIds deviceIds;
      gui = {
        user = config.hostSpec.username;
        # TODO: once password file PR is merged use sops-nix
        password = "$2b$05$DTs1vYGpJnO3NMA3JyfCaudoi8.vfUuB0D4pfZOoXi69m5s/HXIiK";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [guiPort];
  networking.firewall.allowedUDPPorts = [guiPort];
}
