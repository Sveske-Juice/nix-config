{pkgs, ...}: {
  wayland.windowManager.hyprland.settings.exec = [
    "pkill -f ${pkgs.hyprpaper};${pkgs.hyprpaper} & disown"
  ];
  wayland.windowManager.hyprland.settings.exec-once = [
    # When managed by UWSM we use systemd
    "systemctl --user start hyprpolkitagent"

    "${pkgs.waybar} 2>&1 > /tmp/waybarlog.txt"
    "${pkgs.syncthingtray} --wait & disown"
    "wl-paste --watch ${pkgs.cliphist} store & disown"
  ];
}
