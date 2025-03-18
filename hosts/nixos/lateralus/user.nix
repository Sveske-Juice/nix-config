{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
  sops.secrets.sveske-password.neededForUsers = true;
  users.mutableUsers = false;

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "sveske" = import ../../../home/sveske/home.nix;
    };
  };

  users.users.sveske = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.sveske-password.path;
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
