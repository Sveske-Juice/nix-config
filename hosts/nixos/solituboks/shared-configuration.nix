# This configuration is shared between lateralus & lateralus-vm
{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Required
    ../../common/core

    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.default
    inputs.stylix.nixosModules.stylix

    # Optional
    ../../common/optional/drivers/pipewire.nix
    (import ../../common/optional/drivers/bluetooth.nix {
      mpris-proxy = true;
      inherit lib;
      inherit pkgs;
    })

    ../../../hosts/common/optional/services/greetd.nix
    ../../../hosts/common/optional/services/lact.nix
    ../../../hosts/common/optional/services/syncthing/solituboks.nix
    ../../../hosts/common/optional/programs/dolphin.nix

    ../../../home/common/optional/stylix
    ../../../home/common/optional/desktops/qt.nix

    ../../common/optional/hyprland.nix

    ../../common/optional/git.nix
    ../../common/optional/neovim.nix

    ./user.nix
    ./boot.nix
    ./networking.nix
    ./pkgs.nix
  ];

  hostSpec = {
    hostName = "solituboks";
    username = "redux"; # primary user
    handle = "Sveske-Juice";
    email = "carl.benjamin.dreyer@gmail.com";
    domain = "deprived.dev";
    userFullName = "Sveske Juice";
  };

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  environment.sessionVariables = {
    # https://discussion.fedoraproject.org/t/gdk-message-error-71-protocol-error-dispatching-to-wayland-display/127927/1
    GSK_RENDERER = "gl";
  };

  system.stateVersion = "24.11";
}
