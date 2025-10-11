{
  pkgs,
  inputs,
  lib,
  config,
  hostSpec,
  ...
}:
let
  scaling = 1.666667;
in
{
  imports = [
    # Required
    ../common/core/default.nix

    inputs.spicetify-nix.homeManagerModules.default

    ../common/optional/desktops/services/dunst.nix
    ../common/optional/desktops/gtk.nix
    ../common/optional/desktops/qt.nix

    ../common/optional/desktops/tofi.nix
    ../common/optional/desktops/wlogout.nix
    ../common/optional/programs/alacritty.nix
    ../common/optional/programs/spicetify.nix
    ../common/optional/programs/ocr.nix
    ../common/optional/programs/librewolf.nix

    ../common/optional/programs/lutris.nix

    (import ../common/optional/desktops/hyprland {
      inherit pkgs;
      inherit (config) hyprlandSpec;
    })
    (import ../common/optional/desktops/waybar {
      inherit lib;
      inherit (config) barSpec;
    })

    ./sops.nix
  ];

  xresources.extraConfig = ''
    Xft.dpi: ${toString (builtins.floor (96 * scaling))}
    Xft.autohint: 0
    Xft.lcdfilter:  lcddefault
    Xft.hintstyle:  hintfull
    Xft.hinting: 1
    Xft.antialias: 1
    Xft.rgba: rgb
  '';

  home.sessionVariables = {
    GDK_SCALE = (toString scaling);
  };
  hyprlandSpec = {
    monitors = [
      "HDMI-A-1, preffered, 0x0, 1"
      "DP-3, preffered, auto, ${toString scaling}"
      ", preffered, auto, 1" # plug in random monitors
    ];
    workspaces = [
      "1, monitor:DP-3"
      "2, monitor:DP-3"
      "3, monitor:HDMI-A-1"
    ];
  };

  barSpec = {
    battery = false;
    displayDevices = [
      "DP-3"
      "HDMI-A-1"
    ];
  };
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
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
    obsidian

    wl-clipboard

    libnotify
    grimblast
    python3
    blender
    gimp
    obs-studio
  ];
  nixpkgs.config.allowUnfree = true;

  stylix.targets.waybar.enable = false;
  stylix.targets.neovim.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "spotify" ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
