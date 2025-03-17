{
  lib,
  root-disk ? throw "no root disk",
  swap-size ? -1,
  ...
}: {
  # boot.initrd.luks.devices = {
  #   luksroot.device = "${root-disk}${if swap-size != -1 then "3" else "2"}";
  # };
  # boot.initrd.luks.devices.cryptroot.device = root-disk;
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = root-disk;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            swap = lib.mkIf (swap-size != -1) {
              size = swap-size;
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
