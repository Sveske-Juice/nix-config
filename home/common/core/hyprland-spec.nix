{ lib, ... }:
{
  options.hyprlandSpec = {
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ",preffered,auto,1" ];
      description = "Monitors hyprland config";
    };
    workspaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Workspaces hyprland config";
    };
  };
}
