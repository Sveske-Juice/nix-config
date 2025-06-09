{ lib, ... }:
{
  imports = [ ./core.nix ];
  services.syncthing = {
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
