{
  pkgs,
  inputs,
  lib,
  ...
}: let
  username = "sveske";
in {
  imports = [
    # Required
    ../common/core/default.nix

    inputs.spicetify-nix.homeManagerModules.default

    ../common/optional/desktops/services/dunst.nix
    ../common/optional/desktops/gtk.nix

    ../common/optional/desktops/waybar
    ../common/optional/desktops/tofi.nix
    ../common/optional/desktops/wlogout.nix
    ../common/optional/programs/alacritty.nix
    ../common/optional/programs/spicetify.nix
    ../common/optional/programs/ocr.nix

    ../common/optional/desktops/hyprland
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    firefox
    legcord # Discord (armcord)
    pfetch
    nsxiv
    mpv
    keepassxc
    kooha

    wl-clipboard
    libnotify
    grimblast
    python3
  ];

  stylix.targets.waybar.enable = false;
  stylix.targets.neovim.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
    ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
