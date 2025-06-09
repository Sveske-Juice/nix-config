{
  lib,
  config,
  pkgs,
  ...
}:
{
  # Kernel boot parameters
  boot.kernelParams = [ "quit" ];

  # Systemd-boot Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [
    "nouveau"
    "sp5100_tco"
  ]; # No watchdogs

  # boot.initrd.luks.devices."luks-276fc3ee-9365-404d-8ffd-02385d62fecc".device = "/dev/disk/by-uuid/276fc3ee-9365-404d-8ffd-02385d62fecc";
}
