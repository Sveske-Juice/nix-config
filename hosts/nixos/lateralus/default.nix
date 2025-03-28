{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./shared-configuration.nix
    ../../common/optional/drivers/nvidia.nix

    (import ./disko.nix { inherit lib; root-disk = "/dev/nvme0n1"; swap-size = "16G";})
  ];
}
