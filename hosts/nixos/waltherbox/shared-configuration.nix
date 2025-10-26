# This configuration is shared between waltherbox and waltherbox-vm
{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    # Required
    ../../common/core

    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.default

    ../../common/optional/services/openssh.nix

    (import ../../common/optional/torrentvm)

    (import ../../common/optional/networking-shared.nix {
      hostname = config.hostSpec.hostName;
    })

    ../../common/optional/neovim.nix

    ../../common/optional/git.nix

    # Services
    ../../common/optional/services/radicale.nix
    ../../common/optional/services/sonarr.nix
    ../../common/optional/services/radarr.nix
    ../../common/optional/services/jellyseerr.nix
    ../../common/optional/services/nginx.nix
    ../../common/optional/services/forgejo.nix
    ../../common/optional/services/sftp-deprived.nix
    ../../common/optional/services/sftp-media.nix
    ../../common/optional/services/zhen-borg-chroot.nix
    ../../common/optional/services/grafana.nix
    ../../common/optional/services/syncthing/waltherbox.nix
    ../../common/optional/services/immich.nix

    ../../common/optional/services/deprived-site.nix
    ../../common/optional/services/shadowsocks.nix

    ../../common/optional/services/declarative-jellyfin
    ../../common/optional/services/wireguard/wireguard-server.nix

    # Waltherbox specifics
    ./user.nix
  ];

  # Ensure we have a data directory

  hostSpec = {
    hostName = "waltherbox";
    username = "walther"; # primary user
    handle = "Sveske-Juice";
    email = "carl.benjamin.dreyer@gmail.com";
    domain = "deprived.dev";
    userFullName = "Walther";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  # Microcode
  hardware.enableRedistributableFirmware = true;

  programs.nano.enable = false;

  environment.variables = {
    EDITOR = "vim";
  };

  security.sudo = {
    enable = true;
    # I know what im doing
    extraConfig = ''
      Defaults  lecture = never
    '';
  };

  system.stateVersion = "24.11";
}
