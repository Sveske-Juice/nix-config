{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.qtsvg # icons
    kdePackages.kio-fuse # to mount remote filesystems via FUSE
    kdePackages.kio-extras # extra protocols support (sftp, fish and more)

    # thumbnails https://wiki.archlinux.org/title/Dolphin#File_previews
    kdePackages.ffmpegthumbs
    kdePackages.kdegraphics-thumbnailers
    kdePackages.qtimageformats
    kdePackages.kimageformats
  ];
}
