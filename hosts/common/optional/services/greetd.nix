{
  config,
  lib,
  pkgs,
  ...
}: let
  swayConfig = pkgs.writeText "greetd-sway-config" ''
    exec "${pkgs.greetd.regreet}/bin/regreet; ${pkgs.sway}/bin/swaymsg exit"
    include /etc/sway/config.d/*
  '';
  hyprlandRun = pkgs.writeShellScriptBin "hyprland-run" ''
    dbus-run-session ${pkgs.sway}/bin/sway --unsupported-gpu --config ${swayConfig}
  '';
in {
  imports = [
    ./regreet.nix
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # command = "${pkgs.sway}/bin/sway --unsupported-gpu --config ${swayConfig}";
        # https://github.com/cage-kiosk/cage/issues/169#issuecomment-691659377
        #command = "dbus-run-session ${pkgs.cage}/bin/cage gtkgreet";
        command = "${hyprlandRun}/bin/hyprland-run";
      };
    };
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = 1;
  };

  environment.etc."greetd/environments".text = ''
    Hyprland
    ${pkgs.uwsm}/bin/uwsm start -S hyprland-uwsm.desktop
  '';
}
