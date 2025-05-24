{
  lib,
  ...
}: {
  options.barSpec = {
    battery = lib.mkOption {
      type = lib.types.bool;
      description = "Whether the host for this bar has a battery";
    };
    displayDevices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The displays to show this bar on";
      example = [
        "eDP-1"
        "HDMI-A-1"
        "DP-3"
      ];
    };
  };
}
