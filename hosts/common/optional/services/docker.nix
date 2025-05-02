{...}: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    enableOnBoot = false;
  };
}
