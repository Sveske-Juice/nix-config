{ pkgs, peer-port, ... }:
let
  downloadDir = "/buffer/torrents";
  incompleteDir = "/buffer/torrents/.incomplete";
in
{
  users.groups.data = { };
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
      inherit peer-port;
      peer-port-random-on-start = false;
      download-queue-enabled = false;

      rpc-authentication-required = false;
      rpc-whitelist = [
        "10.*.*.*"
        "192.168.*.*"
      ];
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = "1";
    };
    downloadDirPermissions = "775";
    performanceNetParameters = true;
  };

  # HACK: workaround for https://github.com/NixOS/nixpkgs/issues/98904#issuecomment-716656576
  systemd.services.transmission.serviceConfig."BindReadOnlyPaths" =
    "/run/systemd/resolve/stub-resolv.conf";
}
