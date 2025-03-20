{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
    passwd = "passwords/lateralus/sveske"; 
in{
  sops.secrets.${passwd}.neededForUsers = true;
  users.mutableUsers = false;

  home-manager = {
    extraSpecialArgs = {
        inherit inputs;
        inherit (config) hostSpec;
    };
    users = {
      "sveske" = import ../../../home/sveske/home.nix;
    };
  };

  users.users.sveske = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.${passwd}.path;
    description = "Sveske Juice";
    extraGroups = ["networkmanager" "wheel" "audio"];
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      "nrb" = "sudo nixos-rebuild switch --flake /etc/nixos";
    };
  };
}
