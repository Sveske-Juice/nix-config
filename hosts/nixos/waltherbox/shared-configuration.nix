# This configuration is shared between waltherbox and waltherbox-vm
{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    # Required
    ../../common/core

    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.default

    (import ../../common/optional/services/openssh.nix {
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdL+xxxty9n3W2DuXWlq+ciD+K4MMQ24zRFJjGTTlTE9Vnj4CwHClba4lQ7fNwZcLrUrWdTs3HOz0hGrXYQDw6gp3F28U5TIMfyLiUdPwj73Gx/Vom/Ub5Tr7VQT11Jb22WpqrGcUVbmwPUBvUva9L4GD0D+Q1w85Ze2K+9EsWQ4ODeVVsdEivw2NafMYDBUx2bcuNM/Wv2R1hf7uw4OI9oLenMmHBmW/25/G4dg/0OIUG8WVfUXEaC6Bp3hbval8miCx5aIse8pZ5nvPHXHTdW0iA53K3WmFiGONuwCq5NuFlRoqaa8TCXWkQ5MfbhvYKbOr6QDkveN9t/NnywEQC5K4nZR8Hs4VxOxYsg/LxbtOX7GpL1l7r9N5OrSINA0GPBRc15WGvqkaXLRJAD3XLB3eVEoZkoRZDxZkN411Uqi2iWKMdRasA3Hbx1ZD+8LlVcr4dpP+XuZ46oqUT+JWz8YV17RTjKdW3Mr/8U7v5enu2Kew6Ren5Svv77LHtuO8= redux@Sussybox"
      ];
    })

    (import ../../common/optional/torrentvm)

    (import ../../common/optional/networking-shared.nix {hostname = config.hostSpec.hostName;})

    # Waltherbox specifics
    ./user.nix
  ];

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
