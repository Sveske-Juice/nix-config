{ lib, config, ... }:
{
  imports = [ ./core.nix ];

  systemd.tmpfiles.settings."syncdir" = {
    "${config.services.syncthing.dataDir}" = {
      d = {
        inherit (config.services.syncthing) user group;
        mode = "0770";
      };
    };
  };

  services.syncthing = {
    dataDir = lib.mkForce "/sync";
    user = lib.mkForce "syncthing";
    group = lib.mkForce "data";

    guiAddress = lib.mkForce "0.0.0.0:8384";
    overrideDevices = true;
    settings = {
      gui = {
        password = "$2a$10$GQACCCfDo.BOWCh3nwL4C.PbP220YtqUwStGhgXRIxfjusCmIF4sy";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
  networking.firewall.allowedUDPPorts = [ 8384 ];
}
