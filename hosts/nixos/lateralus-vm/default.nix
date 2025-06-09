{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../lateralus/shared-configuration.nix

    (import ../lateralus/disko.nix {
      inherit lib;
      root-disk = "/dev/vda";
      swap-size = -1;
    })
    ../../common/optional/vm-hardware-configuration.nix
  ];
}
