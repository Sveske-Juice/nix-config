{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.xfconf.enable = true;
  programs.thunar = {
    enable = true;

    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.tumbler.enable = true; # Thumbnail support
}
