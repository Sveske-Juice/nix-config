{config, ...}: let
  port = 9090;
in {
  services.prometheus = {
    enable = true;
    inherit port;

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = ["localhost:${toString port}"];
          }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          {targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"];}
        ];
      }
    ];
  };

  services.prometheus.exporters.node = {
    enable = true;
    disabledCollectors = [
      "timex"
      "nfs"
      "nfsd"
      "btrfs"
      "dmi"
      "filesystem"
      "selinux"
      "time"
      "uname"
      "xfs"
    ];
    enabledCollectors = ["systemd" "processes"];
  };

  networking.firewall.allowedTCPPorts = [port];
}
