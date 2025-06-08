{
  config,
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
    guiAddress = "127.0.0.1:${toString guiPort}";
    dataDir = config.hostSpec.home;
    user = config.hostSpec.username;
    group = config.users.users.${config.hostSpec.username}.group;
    # Wait for: https://github.com/NixOS/nixpkgs/issues/244059
    cert = config.sops.secrets."syncthing/certpem".path;
    key = config.sops.secrets."syncthing/keypem".path;
    settings = {
      devices = deviceIds;
      gui = {
        user = config.hostSpec.username;
        # TODO: once password file PR is merged use sops-nix
        password = "$2b$05$I0ofnse7HEEVqyvgjwD3FOLGiXHbobSUURvud3iR3z6LKi461puyS";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [guiPort];
  networking.firewall.allowedUDPPorts = [guiPort];
}
