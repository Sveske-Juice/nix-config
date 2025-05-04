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
  transmissionWebPort = 9091;
  proto = "9p"; # NOTE: use virtiofs for performance
in {
  # HOST IMPORTS
  imports = [
    microvm.nixosModules.host
    ./host-networking.nix
  ];

  # PORT FORWARDING
  # IDK why we have to do this, see:
  # https://github.com/NixOS/nixpkgs/issues/28721
  networking.firewall.extraCommands = lib.mkForce ''
    iptables -t nat -A PREROUTING -p tcp --dport ${toString jackettPort} -j DNAT --to-destination 10.0.0.${toString vm-index}:${toString jackettPort}
    iptables -t nat -A POSTROUTING -p tcp -d 10.0.0.${toString vm-index} --dport ${toString jackettPort} -j MASQUERADE

    iptables -A FORWARD -p tcp -d 10.0.0.${toString vm-index} --dport ${toString transmissionWebPort} -j ACCEPT
    iptables -t nat -A POSTROUTING -p tcp -d 10.0.0.${toString vm-index} --dport ${toString transmissionWebPort} -j MASQUERADE
  '';

  networking.firewall.allowedTCPPorts = [jackettPort transmissionWebPort];
  networking.firewall.allowedUDPPorts = [jackettPort transmissionWebPort];

  # systemd.services."microvm-secret-access" = {
  #   enable = true;
  #   description = "Add microvm to the group of sops secrets, so VMs can mount secrets";
  #   after = ["sops-nix.service"];
  #   wantedBy = ["multi-user.target"];
  #
  #   serviceConfig = {
  #     ExecStart = "${pkgs.coreutils}/bin/chown -R :${toString config.users.groups.secrets.gid} /run/secrets-for-users.d";
  #   };
  # };

  microvm.vms.torrentvm.config.users.groups.data.gid = config.users.groups.data.gid;

  microvm.vms.torrentvm = {
    # Use host's nixpkgs
    inherit pkgs;

    config = {
      system.stateVersion = "24.11";

      microvm.mem = 1024;
      microvm.vcpu = 2;

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

      # Can only login if they already have access to server shell
      # so no need for double security
      # services.openssh = {
      #   enable = true;
      #   settings = {
      #     PermitRootLogin = "yes";
      #     AllowUsers = null;
      #     PasswordAuthentication = true;
      #     KbdInteractiveAuthentication = lib.mkForce true;
      #   };
      # };

      # VM IMPORTS
      imports = [
        (import ./vm-networking.nix {
          inherit vm-index;
          inherit pkgs;
        })
        (import ./jackett.nix {port = jackettPort;})
        ./transmission.nix
      ];

      # systemd.services.jackettperms = {
      #   enable = true;
      #   description = "Ensure permissions for jackett";
      #   serviceConfig = {
      #     Type = "simple";
      #     ExecStart = ''
      #       /bin/sh -c "chown -R ${config.services.jackett.user}:${config.services.jackett.group} /mnt/jackett
      #     '';
      #   };
      #   before = ["jackett.service"];
      # };

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
        # {
        #   tag = "data";
        #   source = "/data";
        #   mountPoint = "/data";
        #   inherit proto;
        # }
      ];
    };
  };

  system.activationScripts."jackettdatadir" = lib.stringAfter ["var"] ''
    mkdir -p /var/lib/torrentvm/jackett
    chown -R microvm:data /var/lib/torrentvm/jackett
  '';
}
