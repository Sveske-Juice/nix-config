{
  pkgs,
  inputs,
  lib,
  config,
  hostSpec,
  ...
}: {
  imports = [
    # Required
    ../common/core/default.nix

    inputs.spicetify-nix.homeManagerModules.default

    ../common/optional/desktops/services/dunst.nix
    ../common/optional/desktops/gtk.nix

    ../common/optional/desktops/tofi.nix
    ../common/optional/desktops/wlogout.nix
    ../common/optional/programs/alacritty.nix
    ../common/optional/programs/spicetify.nix
    ../common/optional/programs/ocr.nix
    ../common/optional/programs/librewolf.nix

    ../common/optional/desktops/hyprland
    (import ../common/optional/desktops/waybar { barSpec = config.barSpec; })

    ./sops.nix
  ];

  barSpec = {
    battery = false;
    displayDevices = [ "DP-3" "HDMI-A-1" ];
  };

  home.username = hostSpec.username;
  home.homeDirectory = hostSpec.home;

  home.packages = with pkgs; [
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
    blender
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

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
