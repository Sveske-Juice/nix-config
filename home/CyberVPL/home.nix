{
  pkgs,
  hostSpec,
  ...
}:{
  imports = [
    ../common/core
  ];

  home.stateVersion = "24.11";
  home.username = hostSpec.username;
  home.homeDirectory = hostSpec.home;

  home.packages = with pkgs; [
    python3
  ];
}
