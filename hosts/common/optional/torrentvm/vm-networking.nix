{
  vm-index ? throw "no index",
  pkgs,
  ...
}:
let
  mac = "00:00:00:00:00:01";
  vpnendpoint = "placeholder";
  host = "10.0.0.1";
in
{
  networking.useNetworkd = true;
  networking.wireguard.enable = true;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    tcpdump
    netcat-gnu
  ];

  environment.etc."wireguard/wg0.conf" = {
    text = ''
      [Interface]
      PrivateKey = placeholder
      Address = 10.72.166.124/32,fc00:bbbb:bbbb:bb01::9:a67b/128
      DNS = 10.64.0.1

      [Peer]
      PublicKey = placeholder
      AllowedIPs = 0.0.0.0/0,::0/0
      Endpoint = ${vpnendpoint}:51820
    '';
    mode = "0640";
  };

  # TODO: use sops-nix templates to fill in private key

  systemd.services."start-wireguard" = {
    description = "Start wireguard mullvad";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      type = "oneshot";
      ExecStart = pkgs.writeShellScript "wgconf.sh" ''
        ${pkgs.wireguard-tools}/bin/wg-quick up wg0
      '';
      RemainAfterExit = "yes";
    };
  };

  microvm.interfaces = [
    {
      id = "vm${toString vm-index}";
      type = "tap";
      inherit mac;
    }
  ];

  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = mac;
    # This VM's local ip
    address = [ "10.0.0.${toString vm-index}/24" ];

    # The default route goes through the VPN endpoint
    # meaning that if the vpn server or a config error
    # happens, it should be impossible to leak our ip,
    # since there is no other default route that reaches WAN.
    # But we can still access 10.0.0.0/24 and 192.168.1.0/24
    routes = [
      {
        # Route all trafic to VPN
        Destination = "0.0.0.0/0"; # default route
        Gateway = "${vpnendpoint}";
        GatewayOnLink = true;
      }
      {
        # All traffic going to VPN must go through host
        Destination = "${vpnendpoint}";
        Gateway = host;
        GatewayOnLink = true;
      }
      {
        # Access 10.0.0.0/24 without VPN
        Destination = "10.0.0.0/24";
        Gateway = host;
        GatewayOnLink = true;
      }
      {
        # Access 192.168.1.0/24 without VPN
        Destination = "192.168.1.0/24";
        Gateway = host;
        GatewayOnLink = true;
      }
    ];

    networkConfig = {
      DNS = [
        "192.168.1.1"
        "9.9.9.9"
        "1.1.1.1"
      ];
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [ (builtins.readFile ../../keys/id_walther.pub) ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      AllowUsers = null;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
