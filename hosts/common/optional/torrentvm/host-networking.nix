# Networking configuration for the host
{lib, ...}: let
  maxVMs = 32;
  hostInterface = "enp11s0";
  wgPort = 51820;
in {
  networking.useNetworkd = true;

  # Create network foreach VM
  # so incomming traffic gets routed to
  # the correct internal vm which is behind NAT
  systemd.network.networks = builtins.listToAttrs (
    map (index: {
      name = "30-vm-${toString index}";
      value = {
        matchConfig.Name = "vm${toString index}";
        # Host's addresses
        address = ["10.0.0.1/32"];
        # Routes to the VM
        routes = [
          {
            Destination = "10.0.0.${toString index}/32";
          }
        ];

        networkConfig = {
          IPv4Forwarding = true;
        };
      };
    }) (lib.genList (i: i + 1) maxVMs)
  );

  networking.nat = {
    enable = true;
    # The new LAN for VMs
    internalIPs = ["10.0.0.0/24"]; # subnet mask 255.255.255.0
    externalInterface = hostInterface;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [];
    allowedUDPPortRanges = [];
  };
}
