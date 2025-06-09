{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = "mouse";
        width = "300";
        height = "300";
        offset = "10x50";
        scale = 0;
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_corner_radius = 5;
        icon_corner_radius = 0;

        seperator_height = 2;

        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;

        frame_width = 1;
        gap_size = 0;

        seperator_color = "auto";

        sort = "yes";

        format = ''
          <b>%s</b>
          %b'';

        alignment = "right";
        vertical_alignment = "center";

        ellipsize = "middle";

        stack_duplicates = false;
        show_indicators = false;
      };
      "[spotify-album-art-waybar]" = {
        appname = "Spotify";
        script = builtins.toString (
          pkgs.writeShellScript "album_art.sh" ''
            #!/bin/bash
            album_art=$(${pkgs.playerctl}/bin/playerctl -p spotify metadata mpris:artUrl)
            if [[ -z $album_art ]]
            then
                # spotify is dead, we should die too.
                exit
            fi
            ${pkgs.curl}/bin/curl -s  "''${album_art}" --output "/dev/stdout"
            #echo "/tmp/cover.jpeg"
          ''
        );
      };
    };
  };
}
