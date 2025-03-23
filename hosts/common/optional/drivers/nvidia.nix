{lib, config, pkgs,  ... }:
{
    nixpkgs.config.nvidia.acceptLicense = true;
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics = {
        enable = true;
    };

    hardware.nvidia = {
        open = false; # Don't use nouveau
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        modesetting.enable = true;
    };
}
