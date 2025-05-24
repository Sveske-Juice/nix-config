{pkgs, ...}:{
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # opencl
  hardware.opengl.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];
}
