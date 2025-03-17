{
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    papirus-folders
    #(tela-icon-theme.override { colorVariants = [ "black" ]; })
  ];
  gtk = {
    enable = true;
    # Use nix build nixpks#<icon-pack> and ls result/share/icons
    # to get the name of the themes
    iconTheme = {
      name = "Tela-black-dark";
      package = pkgs.tela-icon-theme;
    };
  };
}
