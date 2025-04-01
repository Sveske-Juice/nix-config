{
  lib,
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    brightnessctl
    nvtopPackages.full
  ];
}
