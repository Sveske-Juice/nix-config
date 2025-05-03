{
  pkgs,
  root-disk ? throw "Expected a mf disk brother",
  raid-disks ? [],
  swap-size ? -1,
  ...
}: let
  lib = pkgs.lib;
in {
  imports = [
    ./zed.nix # Notification daemon
  ];

  boot.zfs.devNodes = "/dev/disk/by-path";

  environment.systemPackages = with pkgs; [
    zfs
  ];

  disko.devices = {
    disk =
      {
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
              root = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      }
      # Import all disks into raid named "raid5"
      // lib.attrsets.genAttrs raid-disks (name: {
        type = "disk";
        device = "/dev/" + name;
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "raid5";
              };
            };
          };
        };
      });

    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          # Dont need SELinux - better IO performance
          # acltype = "posixacl";
          # xattr = "sa";
        };

        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };

          "nix/store" = {
            type = "zfs_fs";
            mountpoint = "/nix/store";
          };

          var = {
            type = "zfs_fs";
            mountpoint = "/var";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          srv = {
            type = "zfs_fs";
            mountpoint = "/srv";
          };
          opt = {
            type = "zfs_fs";
            mountpoint = "/opt";
          };
        };
      };

      raid5 = lib.mkIf (builtins.length raid-disks > 0) {
        type = "zpool";
        mode = "raidz";

        rootFsOptions = {
          mountpoint = "none";
          # acltype = "posixacl";
          # xattr = "sa";
        };

        datasets = {
          data = {
            type = "zfs_fs";
            mountpoint = "/data";
          };
        };
      };
    };
  };

  # NOTE: this is important
  # it's to stop both zfs and systemd of trying
  # to mount /data, see here:
  # https://github.com/nix-community/disko/issues/581
  fileSystems."/data".options = ["noauto"];
}
