{
  pkgs,
  barSpec,
  ...
}:
{
  programs.waybar = {
    enable = true;
  };
  programs.waybar.settings = {
    mainBar = {
      height = 26;
      layer = "top";
      position = "top";
      output = barSpec.displayDevices;
      modules-left = [
        "tray"
        "hyprland/workspaces"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "idle_inhibitor"
        "wireplumber"
        "network"
        "cpu"
        (pkgs.lib.optionalString barSpec.battery "battery")
        "custom/powermenu"
      ];
      tray = {
        icon-size = "24";
        spacing = "15";
      };
      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        warp-on-scroll = false;
        format = "{icon}";
        format-icons = {
          urgent = "";
          active = "";
          default = "";
          empty = "";
        };
      };
      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
      wireplumber = {
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; # Toggle mute
        on-click-right = "${pkgs.pwvucontrol}/bin/pwvucontrol";
        reverse-scrolling = "1";
        format = "{icon} ";
        format-muted = " ";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [
            ""
            ""
            ""
          ];
        };
      };
      network = {
        justify = "center";
        format-wifi = " ";
        format-ethernet = " ";
        tooltip-format = "{ifname} via {gwaddr}";
        format-linked = "{ifname} (No IP)";
        format-disconnected = "󰖪 ";
      };
      cpu = {
        format = " ";
        tooltip = "true";
        on-click = "$TERMINAL -e btop";
      };
      memory = {
        format = "  {}%";
        tooltip = "true";
      };
      temperature = {
        interval = "10";
        critical-threshold = "50";
        format = "{temperatureC}°C {icon}";
        format-critical = "{temperatureC}°C {icon} ";
        format-icons = [
          ""
          ""
          ""
        ];
      };
      battery = {
        interval = "10";
        full-at = "95";
        states = {
          good = "85";
          warning = "25";
          critical = "15";
        };
        format = "{icon} {capacity}%";
        format-not-charging = "  {capacity}%";
        format-charging = " {capacity}%";
        format-plugged = " {capacity}%";
        format-discharging = "{icon}  {capacity}%";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
      };
      clock = {
        format = "{:L%A %H:%M}";
        format-alt = "{:L%d %B W%V %Y}";
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>'';
      };
      "custom/powermenu" = {
        on-click = "wlogout";
        format = "⏻ ";
        tooltip-format = "Power options";
      };
    };
  };
  programs.waybar.style = ''
    ${builtins.readFile ./style.css}
  '';
}
