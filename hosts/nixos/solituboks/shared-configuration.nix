# This configuration is shared between lateralus & lateralus-vm
{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
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
    ../../../hosts/common/optional/programs/steam.nix
    ../../../hosts/common/optional/programs/wine.nix
    ../../../hosts/common/optional/programs/thunderbird.nix
    ../../../hosts/common/optional/programs/mullvad-vpn.nix

    ../../../home/common/optional/stylix

    ../../common/optional/hyprland.nix
    ../../common/optional/plymouth.nix

    ../../common/optional/git.nix
    ../../common/optional/neovim.nix
    ../../common/optional/adb.nix

    (import ../../../hosts/common/optional/deploy-gpg.nix {
      sopsKeyPath = "gpg/key";
      sopsPasswdPath = "gpg/passwd";
      inherit pkgs;
      inherit config;
    })

    # ../../../hosts/common/optional/services/ollama.nix

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
    publicGPGKey = "B84B7BB6657C51049AFDA0D944BD32B6FA3B5DB0";
  };

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  environment.sessionVariables = {
    # https://discussion.fedoraproject.org/t/gdk-message-error-71-protocol-error-dispatching-to-wayland-display/127927/1
    GSK_RENDERER = "gl";
  };

  system.stateVersion = "24.11";
}
