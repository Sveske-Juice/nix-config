{
  pkgs,
  inputs,
  config,
  ...
}: let
  main-user = "walther";
  passwd = "passwords/waltherbox/${main-user}";
  rootpasswd = "passwords/waltherbox/root";
in {
  sops.secrets.${passwd}.neededForUsers = true;
  users.mutableUsers = false;

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      ${main-user} = import ../../../home/walther/home.nix;
    };
  };

  users.users.${main-user} = {
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
    hashedPasswordFile = config.sops.secrets.${rootpasswd}.path;
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      "nrb" = "sudo nixos-rebuild switch --flake /etc/nixos";
    };
  };

  # Authorized SSH keys
  users.extraUsers.${main-user}.openssh.authorizedKeys.keys = [
    (builtins.readFile ../../common/keys/id_sveske.pub)
    (builtins.readFile ../../common/keys/id_redux.pub)
  ];
}
