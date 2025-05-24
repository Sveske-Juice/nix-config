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
    ./disko.nix
  ];
}
