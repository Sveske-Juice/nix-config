{pkgs, ...}: let
  downloadDir = "/buffer/torrents";
  incompleteDir = "/buffer/torrents/.incomplete";
in {
  users.groups.data = {};
  services.transmission = {
    enable = true;
    group = "data";
    openPeerPorts = true;
    openRPCPort = true;
    home = "/mnt/transmission";
    webHome = "${pkgs.flood-for-transmission}";
    settings = {
      download-dir = downloadDir;
      incomplete-dir = incompleteDir;
      peer-port-random-low = 65500;
      peer-port-random-high = 65535;
      peer-port-random-on-start = true;
      download-queue-enabled = false;

      rpc-authentication-required = false;
      rpc-whitelist = ["10.*.*.*" "192.168.*.*"];
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = "1";
    };
    downloadDirPermissions = "775";
    performanceNetParameters = true;
  };
}
