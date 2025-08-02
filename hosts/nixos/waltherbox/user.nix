{
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
      inherit (config) hostSpec; # Pass hostSpec to homemanager configurations
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
      "data"
    ];

    shell = pkgs.fish;
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets.${rootpasswd}.path;
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  # Authorized SSH keys
  users.extraUsers.${config.hostSpec.username}.openssh.authorizedKeys.keys = [
    (builtins.readFile ../../common/keys/id_sveske.pub)
    (builtins.readFile ../../common/keys/id_redux.pub)
    (builtins.readFile ../../common/keys/id_pixel8a.pub)
  ];
}

