{ pkgs, config, ... }:
let
  port = 8388;
in
{
  sops.secrets.shadowsocks = { };
  services.shadowsocks = {
    enable = true;
    mode = "tcp_only";
    inherit port;
    localAddress = "192.168.1.69";
    passwordFile = config.sops.secrets."shadowsocks".path;
    encryptionMethod = "chacha20-ietf-poly1305";
    plugin = "${pkgs.shadowsocks-v2ray-plugin}/bin/v2ray-plugin";
    pluginOpts = "server;path=/v2ray;host=deprived.dev;tls;cert=/var/lib/acme/deprived.dev/fullchain.pem;key=/var/lib/acme/deprived.dev/key.pem";
  };

  networking.firewall.allowedTCPPorts = [ port ];

  # services.nginx.virtualHosts."deprived.dev".locations."/v2ray" = {
  #     proxyPass = "http://127.0.0.1:${toString port}";
  #     proxyWebsockets = true;
  #     extraConfig = ''
  #         proxy_set_header Host $host;
  #         proxy_set_header Upgrade $http_upgrade;
  #         proxy_set_header Connection "upgrade";
  #         proxy_set_header X-Real-IP $remote_addr;
  #         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #     '';
  # };
}
