{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./shared-configuration.nix
    ../../common/optional/drivers/nvidia.nix

    (import ./disko.nix {
      inherit lib;
      root-disk = "/dev/nvme0n1";
      swap-size = "16G";
    })

    # nixos-hardware config
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga502
  ];

  hardware.nvidia.prime.amdgpuBusId = lib.mkForce "PCI:5:0:0";
}
