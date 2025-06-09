{ ... }:
let
  port = 3000;
in
{
  imports = [
    ./nginx.nix
    ./prometheus.nix
  ];
  services.grafana = {
    enable = true;
    settings = {
      server.http_port = port;
      server.http_addr = "0.0.0.0";
    };
  };

  services.nginx.virtualHosts."grafana.casdnas.deprived.dev" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ port ];
  networking.firewall.allowedUDPPorts = [ port ];
}
