{ pkgs, ... }:
{
  wayland.windowManager.hyprland.settings.exec = [
    "pkill -f ${pkgs.hyprpaper}/bin/hyprpaper;${pkgs.hyprpaper}/bin/hyprpaper & disown"
  ];
  wayland.windowManager.hyprland.settings.exec-once = [
    # When managed by UWSM we use systemd
    "systemctl --user start hyprpolkitagent"

    "${pkgs.waybar}/bin/waybar 2>&1 > /tmp/waybarlog.txt"
    "${pkgs.syncthingtray}/bin/syncthingtray --wait & disown"
    "wl-paste --watch ${pkgs.cliphist}/bin/cliphist store & disown"
  ];
}
