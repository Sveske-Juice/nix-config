{
  lib,
  pkgs,
  inputs,
  ...
}: {
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "sveske" = import ../../../home/lateralus/home.nix;
    };
  };

  users.users.sveske = {
    isNormalUser = true;
    hashedPassword = import ./password.nix;
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
