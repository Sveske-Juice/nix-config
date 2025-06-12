{
  pkgs,
  ...
}:
{
  imports = [ ./fonts.nix ];

  stylix.enable = true;
  stylix.image = ../../../../wallpapers/wallhaven-zyl9qg.png;
  stylix.polarity = "dark";

  stylix.base16Scheme =
    "${pkgs.writeText "lackluster.yaml"
      ''
        system: "base16"
        name: "lackluster"
        author: "slugbyte"
        variant: "dark"
        palette:
          base00: "000000"
          base01: "2A2A2A" #  ---
          base02: "444444" #  --
          base03: "555555" #  -
          base04: "AAAAAA" #  +
          base05: "CCCCCC" #  ++
          base06: "DEEEED" #  +++
          base07: "DDDDDD" #  ++++
          base08: "D70000" #   red
          base09: "FFAA88" #   orange
          base0A: "FFAA88" #   yellow
          base0B: "789978" #   green
          base0C: "708090" #   aqua
          base0D: "7788AA" #   blue
          base0E: "7788AA" #   purple
          base0F: "708090" #   brown
      ''}";
}
