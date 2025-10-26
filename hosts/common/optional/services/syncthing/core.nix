# Core config for all my devices with syncthing
{ lib, config, ... }:
let
  idFiles = lib.attrNames (builtins.readDir ./devices);
  deviceIds = builtins.listToAttrs (map (file: import (./devices + "/${file}")) idFiles);
  devices = builtins.attrNames deviceIds;
in
{
  sops.secrets."syncthing/certpem" = {
    owner = config.services.syncthing.user;
    group = config.services.syncthing.group;
  };

  sops.secrets."syncthing/keypem" = {
    owner = config.services.syncthing.user;
    group = config.services.syncthing.group;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    # Only open to localhost by default
    guiAddress = "127.0.0.1:8384";
    dataDir = config.hostSpec.home;
    user = config.hostSpec.username;
    group = config.users.users.${config.hostSpec.username}.group;
    cert = config.sops.secrets."syncthing/certpem".path;
    key = config.sops.secrets."syncthing/keypem".path;

    settings = {
      devices = deviceIds;
      gui = {
        user = config.hostSpec.username;
        # TODO: once password file PR is merged use sops-nix
      };
      folders = {
        pictures = {
          path = "${config.hostSpec.home}/Pictures";
          devices = devices;
        };
        benj-next = {
          path = "${config.hostSpec.home}/Documents/NEXT";
          devices = devices;
        };
        notes = {
          path = "${config.hostSpec.home}/Documents/Notes";
          devices = devices;
        };
        benj-secrets = {
          path = "${config.hostSpec.home}/Documents/Secrets";
          devices = devices;
        };
      };
    };
  };
}
