{ config, ... }:
{
  users.groups.www = { };
  sops.secrets.ollama-auth = {
    owner = config.services.nginx.user;
    group = config.services.nginx.group;
  };

  services.nginx = {
    enable = true;
    group = "www";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    statusPage = true;
  };

  services.nginx.virtualHosts."ollama.deprived.dev" = {
    forceSSL = true;
    enableACME = true;
    http2 = true;
    locations = {
      "/" = {
        basicAuthFile = config.sops.secrets.ollama-auth.path;
        proxyPass = "http://192.168.1.70:11434";
      };
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "carl.benjamin.dreyer@gmail.com";
  security.acme.defaults.group = "www";

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
  ];
}
