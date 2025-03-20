{
  pkgs,
  inputs,
  config,
  ...
}: let
  passwd = "passwords/${config.hostSpec.hostName}/${config.hostSpec.username}";
  rootpasswd = "passwords/${config.hostSpec.hostName}/root";
in {
  sops.secrets.${passwd}.neededForUsers = true;
  users.mutableUsers = false;

  home-manager = {
    extraSpecialArgs = {
        inherit inputs;
        inherit (config) hostSpec;
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
      "audio"
      "wheel"
    ];

    shell = pkgs.fish;
  };

  users.users.root = {
    password = "123";
    # hashedPasswordFile = config.sops.secrets.${rootpasswd}.path;
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      "nrb" = "sudo nixos-rebuild switch --flake /etc/nixos";
    };
  };

  # Authorized SSH keys
  users.extraUsers.${config.hostSpec.username}.openssh.authorizedKeys.keys = [
    (builtins.readFile ../../common/keys/id_sveske.pub)
    (builtins.readFile ../../common/keys/id_redux.pub)
  ];
}
