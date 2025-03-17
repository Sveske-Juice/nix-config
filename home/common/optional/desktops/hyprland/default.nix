{
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    playerctl
    cliphist
    hyprpicker
  ];
  imports = [
    ./exec.nix
    ./hyprlock.nix
    ./hypridle.nix
  ];

  /*
  xdg.portal = {
  config = {
  common = {
  default = [
  "hyprland"
  "gtk"
  ];
  };
  };
  configPackages = with pkgs; [
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk
  ];
  };
  */

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      autogenerated = false;
      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
      };
      monitor = [
        ",preffered,auto,1"
      ];
      input = {
        kb_layout = "dk";
        follow_mouse = true;
        touchpad.natural_scroll = true;
      };
      "$mod" = "super";
      bind =
        [
          "$mod, Return, exec, alacritty"
          "$mod, D, exec, tofi-drun | /bin/sh"
          "$mod, E, exec, thunar"
          "$mod SHIFT, S, exec, grimblast --freeze copy area"
          "$mod SHIFT, E, exec, hyprctl dispatch exit"
          "$mod, V, exec, cliphist list | tofi | cliphist decode | wl-copy"
          "$mod, P, exec, hyprpicker -a | wl-copy" # Hex -> clipboard

          # Window Management
          "$mod, Q, killactive"
          "$mod SHIFT, V, togglefloating"
          "$mod, F, fullscreen"

          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"
        ]
        ++ (
          # Auto generate workspace switching from [0-9] and shift + [0-9]
          builtins.concatLists (builtins.genList
            (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      bindel = [
        # Media controls
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        # Backlight Controls
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
        # KBD backlight
        ", XF86KbdBrightnessUp, exec, brightnessctl -d '*kbd_backlight*' set +10%"
        ", XF86KbdBrightnessDown, exec, brightnessctl -d '*kbd_backlight*' set 10%-"
      ];
      decoration = {
        rounding = "5";
      };
      gestures = {
        workspace_swipe = true;
      };
    };
  };
}
