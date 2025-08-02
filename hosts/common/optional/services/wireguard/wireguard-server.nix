{
  pkgs,
  config,
  ...
}:
{
  sops.secrets."wireguard/server-private" = {
    owner = "systemd-network";
    group = "systemd-network";
  };
  environment.systemPackages = [
    pkgs.wireguard-tools
  ];

  networking.nat = {
    enable = true;
    externalInterface = "enp6s0";
    internalInterfaces = [ "wg0" ];
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.useNetworkd = true;

  systemd.network = {
    enable = true;
    netdevs = {
      "50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.sops.secrets."wireguard/server-private".path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = "1N+8G1nCf82xMKX8OBdOGt+xcAYz8ICag6s4iv5drlc=";
            AllowedIPs = [ "10.100.0.2" ];
          }
        ];
      };
    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = [ "10.100.0.1/24" ];
      networkConfig = {
        IPMasquerade = "ipv4";
        IPv4Forwarding = true;
      };
    };
  };

  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
  '';
}
