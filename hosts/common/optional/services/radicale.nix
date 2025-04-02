{config, ...}: let
  port = 5232;
in {
  sops.secrets.radicale-htpasswd = {
    owner = "radicale";
  };

  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = ["0.0.0.0:${toString port}" "[::]:${toString port}"];
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = "${config.sops.secrets.radicale-htpasswd.path}";
        htpasswd_encryption = "autodetect";
      };
      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [port];
}
