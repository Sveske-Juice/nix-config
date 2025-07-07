{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    winetricks
    protontricks
    wineWowPackages.waylandFull
    protonup-qt
  ];
}
