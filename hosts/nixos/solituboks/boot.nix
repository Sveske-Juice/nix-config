{
  lib,
  config,
  pkgs,
  ...
}: {
  # Kernel boot parameters
  boot.kernelParams = [
    "quit"
  ];

  # Systemd-boot Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
