{
  lib,
  config,
  pkgs,
  ...
}:
# https://discourse.nixos.org/t/struggling-to-configure-gtk-qt-theme-on-laptop/42268/4
/*
   {
    environment.systemPackages = with pkgs; [
      libsForQt5.qt5ct
      adwaita-qt
      adwaita-qt6
    ];

    environment.sessionVariables = {
        QT_QPA_PLATFORM="wayland";
        QT_QPA_PLATFORMTHEME="qt5ct";
        # QT_STYLE_OVERRIDE = "adwaita-dark";
    };

    qt.enable = true;
    qt.platformTheme = "qt5ct";
}
*/
{
  # idk why nothing works
  qt = {
    enable = true;
    style = lib.mkForce "gtk2";
    platformTheme = lib.mkForce "gtk2";
  };
  environment.systemPackages = with pkgs; [
    libsForQt5.qtstyleplugins
    #other stuff
  ];
}
