{
    pkgs,
    lib,
    ...
}: {
    boot.zfs.devNodes = "/dev/disk/by-path";

    environment.systemPackages = with pkgs; [
        zfs
    ];
}
