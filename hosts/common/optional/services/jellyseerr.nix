{ config, ... }:
{
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  services.nginx.virtualHosts."jellyseerr.casdnas.deprived.dev" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.jellyseerr.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
