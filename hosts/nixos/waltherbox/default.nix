# This file only contains config specific for HW version of waltherbox
{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./shared-configuration.nix

    (import ../../common/optional/zfsraid-disko.nix {
      pkgs = pkgs;
      swap-size = "16G";
      root-disk = "/dev/nvme0n1";
      raid-disks = [
        "sda"
        "sdb"
        "sdc"
      ];
    })
  ];
}
