{lib, config, pkgs, ... }:
{
    # Some QoL audio applications
    environment.systemPackages = with pkgs; [
        # currently broken: https://github.com/NixOS/nixpkgs/issues/389656
        # pwvucontrol # idk it doesn't seem to launch
        pavucontrol
        coppwr
    ];

    services.pipewire = {
        enable = true;

        alsa.enable = true;
        alsa.support32Bit = true;

        pulse.enable = true;

        jack.enable = true;
    };
}
