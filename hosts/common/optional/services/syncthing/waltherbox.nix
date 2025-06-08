{
  config,
  pkgs,
  lib,
  ...
}: let
  guiPort = 8384;
  idFiles = lib.attrNames (builtins.readDir ./devices);
  deviceIds = builtins.listToAttrs (map (file: import (./devices + "/${file}")) idFiles);
in {
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
    guiAddress = "0.0.0.0:${toString guiPort}";
    overrideDevices = true;
    # Wait for: https://github.com/NixOS/nixpkgs/issues/244059
    cert = config.sops.secrets."syncthing/certpem".path;
    key = config.sops.secrets."syncthing/keypem".path;
    settings = {
      devices = deviceIds;
      gui = {
        user = config.hostSpec.username;
        password = "$2a$10$GQACCCfDo.BOWCh3nwL4C.PbP220YtqUwStGhgXRIxfjusCmIF4sy";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [guiPort];
  networking.firewall.allowedUDPPorts = [guiPort];
}
