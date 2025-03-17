{...}: {
  wayland.windowManager.hyprland.settings.exec = [
    "pkill -f hyprpaper;hyprpaper & disown"
  ];
  wayland.windowManager.hyprland.settings.exec-once = [
    # When managed by UWSM we use systemd
    "systemctl --user start hyprpolkitagent"

    "waybar 2>&1 > /tmp/waybarlog.txt"
    "syncthingtray --wait & disown"
    "wl-paste --watch cliphist store & disown"
  ];
}
