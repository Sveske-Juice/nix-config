{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.rocmPackages.clr
  ];
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    acceleration = "rocm";
    openFirewall = true;
    # environmentVariables = {
    #   HCC_AMDGPU_TARGET = "gfx1031"; # used to be necessary, but doesn't seem to anymore
    # };
    # # results in environment variable "HSA_OVERRIDE_GFX_VERSION=10.3.0"
    # rocmOverrideGfx = "10.3.0";
  };
}
