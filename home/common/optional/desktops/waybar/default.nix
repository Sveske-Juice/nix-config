{
  barSpec,
  ...
}: {
  programs.waybar = {
    enable = true;
  };
  programs.waybar.settings = {
    mainBar = {
      height = 30;
      layer = "top";
      position = "top";
      output = barSpec.displayDevices;
      modules-left = [
        "tray"
        "hyprland/workspaces"
      ];
      modules-center = [
        "hyprland/window"
      ];
      modules-right = [
        "idle_inhibitor"
        "wireplumber"
        "network"
        "cpu"
        "memory"
        "temperature"
        "battery"
        "clock"
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
        on-click-right = "pwvucontrol";
        reverse-scrolling = "1";
        format = "{volume}% {icon} ";
        format-muted = "{volume}%  ";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = ["" "" ""];
        };
      };
      network = {
        format-wifi = "   {essid} ({signalStrength}%)";
        format-ethernet = "{ipaddr}/{cidr} ";
        tooltip-format = "{ifname} via {gwaddr}";
        format-linked = "{ifname} (No IP)";
        format-disconnected = "Disconnected ⚠";
      };
      cpu = {
        format = "  {}%";
        tooltip = "true";
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
        format-icons = ["" "" ""];
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
        format-icons = ["" "" "" "" ""];
      };
      clock = {
        format = "{:%H:%M | %e. %B} ";
        format-alt = "{:%d-%m-%Y}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
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
