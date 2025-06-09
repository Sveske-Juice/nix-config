{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  passwd = "passwords/${config.hostSpec.username}";
  rootpasswd = "passwords/root";
in
{
  sops.secrets.${passwd}.neededForUsers = true;
  sops.secrets.${rootpasswd}.neededForUsers = true;
  users.mutableUsers = false;

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit (config) hostSpec; # Pass hostSpec to home manager configurations
    };
    users = {
      ${config.hostSpec.username} = import ../../../home/${config.hostSpec.username}/home.nix;
    };
  };

  users.users.${config.hostSpec.username} = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.${passwd}.path;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
    shell = pkgs.fish;
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets.${rootpasswd}.path;
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      "nrb" = "sudo nixos-rebuild switch --flake /etc/nixos";
    };
  };
}
