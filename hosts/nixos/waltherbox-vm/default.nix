# This file only contains config specific for VM version of waltherbox
{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../waltherbox/shared-configuration.nix
    ../../common/optional/vm-hardware-configuration.nix
    ./hardware-configuration.nix

    (import ../../common/optional/zfsraid-disko.nix {
      pkgs = pkgs;
      swap-size = -1; # no swap in vm
      root-disk = "/dev/vda";
      raid-disks = [
        "vdb"
        "vdc"
        "vdd"
      ];
    })
  ];
}
