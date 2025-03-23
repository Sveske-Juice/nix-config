{mpris-proxy ? false, lib, pkgs, ... }:
{
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    # Blueman
    services.blueman.enable = true;

    # Headset buttons with MPRIS proxy
    systemd.user.services.mpris-proxy = lib.mkIf (mpris-proxy == true) {
        description = "Mpris proxy";
        after = [ "network.target" "sound.target" ];
        wantedBy = [ "default.target" ];
        serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };
}
