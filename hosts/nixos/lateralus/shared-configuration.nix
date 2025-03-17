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
    ../../../modules/locales/en_dk.nix
    ../../../modules/drivers/pipewire.nix
    (import ../../../modules/drivers/bluetooth.nix { mpris-proxy = true; inherit lib; inherit pkgs; })
    ../../../modules/fonts.nix

    ../../../hosts/common/optional/services/greetd.nix
    ../../../hosts/common/optional/services/syncthing.nix
    ../../../hosts/common/optional/programs/thunar.nix

    ../../../home/common/optional/stylix
    ../../../home/common/optional/desktops/qt.nix
    # ../../home/common/optional/desktops/gtk.nix

    ../../../hosts/common/optional/hyprland.nix

    # Laptop specifics
    ./user.nix
    ./boot.nix
    ./networking.nix
    ./pkgs.nix
  ];

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  nixpkgs.config.allowBroken = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    # https://discussion.fedoraproject.org/t/gdk-message-error-71-protocol-error-dispatching-to-wayland-display/127927/1
    GSK_RENDERER = "gl";
  };

  system.stateVersion = "24.11"; # 24.05
}
