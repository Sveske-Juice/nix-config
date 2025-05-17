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

  services.nginx.virtualHosts."radicale.casdnas.deprived.dev" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  networking.firewall.allowedTCPPorts = [port];
}
