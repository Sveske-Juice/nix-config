{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    ../../common/core

    ../../common/optional/neovim.nix
    ../../common/optional/git.nix

    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.default
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";

  wsl.enable = true;

  networking.useDHCP = true;
  networking.hostName = config.hostSpec.hostName;
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  hostSpec = {
    hostName = "PC-5CG3233LFL";
    username = "CyberVPL";
    handle = "Sveske-Juice";
    email = "carl.benjamin.dreyer@gmail.com";
  };

  users.users."${config.hostSpec.username}" = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit (config) hostSpec; # Pass hostSpec to home manager configurations
    };
    users = {
      ${config.hostSpec.username} = import ../../../home/${config.hostSpec.username}/home.nix;
    };
  };

  # https://unix.stackexchange.com/questions/643583/tmux-wont-start-under-wsl2
  environment.variables.TMUX_TMPDIR = lib.mkForce "/tmp";
}
