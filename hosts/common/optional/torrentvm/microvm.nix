{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (inputs) microvm;
  vm-index = 2; # 1 reserved for host 10.0.0.1
  jackettPort = 9117;
  transmissionWebPort = 9091;
  proto = "virtiofs"; # NOTE: use virtiofs for performance
  internetFacingInterface = "enp6s0";
  peer-port = 65535;
in
{
  # HOST IMPORTS
  imports = [
    microvm.nixosModules.host
    ./host-networking.nix
  ];

  # PORT FORWARDING
  # See:
  # https://github.com/NixOS/nixpkgs/issues/28721
  networking.firewall.extraCommands = lib.mkForce ''
    # By default don't forward anything, unless explicitly accepted
    iptables -P FORWARD DROP
    # Accept new connection requests
    iptables -A FORWARD -i ${internetFacingInterface} -o vm${toString vm-index} -p tcp --syn --dport ${toString jackettPort} -m conntrack --ctstate NEW -j ACCEPT
    iptables -A FORWARD -i ${internetFacingInterface} -o vm${toString vm-index} -p tcp --syn --dport ${toString transmissionWebPort} -m conntrack --ctstate NEW -j ACCEPT

    # Allow return traffic on established connections only
    iptables -A FORWARD -i ${internetFacingInterface} -o vm${toString vm-index} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Allow all outgoing traffic from vm to internet facing interface (so vm can reach destinations without being poked first)
    iptables -A FORWARD -i vm${toString vm-index} -o ${internetFacingInterface} -s 10.0.0.${toString vm-index} -j ACCEPT

    # Allow VM to reach the internet without an established connection
    iptables -t nat -A POSTROUTING -o ${internetFacingInterface} -j MASQUERADE

    # NAT
    # peers
    iptables -t nat -A PREROUTING -i ${internetFacingInterface} -p tcp --dport ${toString peer-port} -j DNAT --to-destination 10.0.0.${toString vm-index}
    iptables -t nat -A POSTROUTING -o vm${toString vm-index} -p tcp --dport ${toString peer-port} -d 10.0.0.${toString vm-index}
    iptables -t nat -A PREROUTING -i ${internetFacingInterface} -p udp --dport ${toString peer-port} -j DNAT --to-destination 10.0.0.${toString vm-index}
    iptables -t nat -A POSTROUTING -o vm${toString vm-index} -p udp --dport ${toString peer-port} -d 10.0.0.${toString vm-index}

    # jackett
    iptables -t nat -A PREROUTING -i ${internetFacingInterface} -p tcp --dport ${toString jackettPort} -j DNAT --to-destination 10.0.0.${toString vm-index}
    iptables -t nat -A POSTROUTING -o vm${toString vm-index} -p tcp --dport ${toString jackettPort} -d 10.0.0.${toString vm-index}

    # transmission
    iptables -t nat -A PREROUTING -i ${internetFacingInterface} -p tcp --dport ${toString transmissionWebPort} -j DNAT --to-destination 10.0.0.${toString vm-index}
    iptables -t nat -A POSTROUTING -o vm${toString vm-index} -p tcp --dport ${toString transmissionWebPort} -d 10.0.0.${toString vm-index}
  '';

  networking.firewall.allowedTCPPorts = [
    jackettPort
    transmissionWebPort
    peer-port
  ];
  networking.firewall.allowedUDPPorts = [
    jackettPort
    transmissionWebPort
    peer-port
  ];

  users.users.microvm.extraGroups = [ "data" ];
  users.groups.data.gid = 991;
  microvm.vms.torrentvm.config.users.groups.data = {
    gid = config.users.groups.data.gid;
  };

  microvm.vms.torrentvm = {
    # Use host's nixpkgs
    inherit pkgs;

    config = {
      system.stateVersion = "24.11";

      microvm.mem = 1024;
      microvm.vcpu = 2;

      time.timeZone = "Europe/Copenhagen";

      # Users
      users.users.root = {
        # FIXME:
        # Wait for: https://github.com/astro/microvm.nix/pull/337
        password = "123"; # HACK: Temporary until credentialFiles implemented
        shell = pkgs.fish; # TODO: `useDefaultShell`
      };
      # users.users.test = {
      #   isNormalUser = true;
      #   hashedPasswordFile = builtins.trace passwdPath passwdPath;
      #   extraGroups = ["wheel"];
      # };
      programs.fish.enable = true;
      programs.nano.enable = lib.mkForce false;
      programs.vim.enable = true;

      # VM IMPORTS
      imports = [
        (import ./vm-networking.nix {
          inherit vm-index;
          inherit pkgs;
        })
        (import ./jackett.nix { port = jackettPort; })
        # (import ./transmission.nix { inherit pkgs; inherit peer-port;})
        ./qbittorrent.nix
      ];

      services.qbittorrent = {
        enable = true;
        openFirewall = true;
        group = "data";
        dataDir = "/buffer";
        port = transmissionWebPort;
      };

      microvm.shares = [
        {
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          tag = "ro-store";
          inherit proto;
        }
        {
          tag = "internaldata";
          source = "/var/lib/torrentvm/";
          mountPoint = "/mnt";
          inherit proto;
        }
        {
          tag = "data";
          source = "/buffer";
          mountPoint = "/buffer";
          inherit proto;
        }
      ];
    };
  };
}
