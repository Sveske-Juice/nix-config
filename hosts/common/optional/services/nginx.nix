{...}: {
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    statusPage = true;
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "carl.benjamin.dreyer@gmail.com";

  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [80 443];
}
