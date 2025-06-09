{ lib, pkgs, ... }:
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
  qt = {
    enable = true;
    style.name = lib.mkForce "gtk2";
    style.package = pkgs.libsForQt5.qtstyleplugins;
  };
}
