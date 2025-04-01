{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  inherit (inputs) microvm;
in {
  # HOST IMPORTS
  imports = [
    microvm.nixosModules.host
    ./host-networking.nix
  ];

  sops.secrets."passwords/torrentvmroot".neededForUsers = true;

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
        ./vm-networking.nix
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
