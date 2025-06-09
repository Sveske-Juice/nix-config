{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general.grace = 5;

      input-field = {
        size = "250, 50";
        outline_thickness = 1;
        dots_size = 0.33;
        dots_spacing = 0.15;
        dost_center = false;
        dots_rounding = -1;

        fade_on_empty = false;
        fade_timeout = 4000;

        placeholder_text = ''<span foreground="##e0def4">Input Password...</span>'';
        hide_input = false;
        rounding = 0;

        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        fail_transition = 300;

        numlock_color = -1;
        bothlock_color = -1;
        invert_numlock = false;

        position = "0, -20";
        halign = "center";
        valign = "center";
      };

      label = [
        {
          text = ''cmd[update:1000] echo "<span>$(date +%H:%M:%S)</span>"'';
          color = "rgb(200, 200, 200)";
          font_size = 15;
          font_family = "Noto Sans";

          position = "-10, -10";
          halign = "right";
          valign = "top";
        }

        {
          text = "<span>  $USER</span>";
          color = "rgb(200, 200, 200)";
          font_size = 25;
          font_family = "Noto Sans";

          position = "0, 50";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
