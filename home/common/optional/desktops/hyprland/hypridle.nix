{
  lib,
  config,
  pkgs,
  ...
}: {
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "dunstctl set-paused true; pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
        unlock_cmd = "dunstctl set-paused false";
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
      };

      listener = [
        {
          timeout = 150; # 2.5min.
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r"; # monitor backlight restore
        }

        {
          timeout = 300; # 5min
          on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r"; # monitor backlight restore
        }

        {
          timeout = 380; # 5.5min
          on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
          on-resume = [
            "hyprctl dispatch dpms on" # screen on when activity is detected after timeout has fired.
            "${pkgs.brightnessctl}/bin/brightnessctl -r" # monitor backlight restore
          ];
        }

        {
          timeout = 900; # 15min
          on-timeout = "systemctl suspend-then-hibernate";
        }
      ];
    };
  };
}
