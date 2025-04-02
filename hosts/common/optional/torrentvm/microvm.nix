{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  inherit (inputs) microvm;
  vm-index = 2; # 1 reserved for host 10.0.0.1
  jackettPort = 9117;
in {
  # HOST IMPORTS
  imports = [
    microvm.nixosModules.host
    ./host-networking.nix
  ];

  # PORT FORWARDING
  networking.nat.forwardPorts = [
    {
      destination = "10.0.0.${toString vm-index}:${toString jackettPort}";
      proto = "tcp";
      sourcePort = jackettPort;
    }
  ];

  # IDK why we have to do this, see:
  # https://github.com/NixOS/nixpkgs/issues/28721
  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING -d 10.0.0.${toString vm-index} -p tcp -m tcp --dport ${toString jackettPort} -j MASQUERADE
  '';

  networking.firewall.allowedTCPPorts = [jackettPort];
  networking.firewall.allowedUDPPorts = [jackettPort];

  systemd.services."microvm-secret-access" = {
    enable = true;
    description = "Add microvm to the group of sops secrets, so VMs can mount secrets";
    after = ["sops-nix.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/chown -R :${toString config.users.groups.secrets.gid} /run/secrets-for-users.d";
    };
  };

  users.groups.secrets.gid = 1069;
  users.users.microvm.extraGroups = ["secrets"];

  microvm.vms.torrentvm = let
    passwdPath = config.sops.secrets."passwords/torrentvmroot".path;
  in {
    # Use host's nixpkgs
    inherit pkgs;

    config = {
      system.stateVersion = "24.11";

      microvm.mem = 1024;
      microvm.vcpu = 2;

      users.groups.microvm = {};
      users.users.microvm = {
        isSystemUser = true;
        group = "microvm";
        uid = config.users.users.microvm.uid;
        extraGroups = ["secrets"];
      };
      users.groups.secrets.gid = config.users.groups.secrets.gid;

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
        (import ./jackett.nix {port = jackettPort;})
      ];

      microvm.shares = [
        {
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          tag = "ro-store";
          proto = "9p";
        }
      ];
    };
  };
}
