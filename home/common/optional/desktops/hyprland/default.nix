{ pkgs, hyprlandSpec, ... }:
{
  home.packages = with pkgs; [
    playerctl
    cliphist
    hyprpicker
  ];
  imports = [
    ./exec.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./cursor.nix
  ];

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
      #xdg-desktop-portal-gtk
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = false; # conflicts with uwsm
    xwayland.enable = true;

    extraConfig = ''
      cursor {
        no_hardware_cursors = true
      }
      xwayland {
        force_zero_scaling = true
      }
    '';

    settings = {
      autogenerated = false;
      general.border_size = 0;
      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
      };
      monitor = hyprlandSpec.monitors;
      workspace = hyprlandSpec.workspaces;
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
          "$mod, C, exec, cliphist list | tofi | cliphist decode | wl-copy"
          "$mod, P, exec, hyprpicker -a | wl-copy" # Hex -> clipboard
          "$mod, Z, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; notify-send \"$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)\""

          # Window Management
          "$mod, Q, killactive"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"

          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"
        ]
        ++ (
          # Auto generate workspace switching from [0-9] and shift + [0-9]
          builtins.concatLists (
            builtins.genList (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            ) 10
          )
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
