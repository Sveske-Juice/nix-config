{
  pkgs,
  inputs,
  config,
  ...
}: let
  main-user = "walther";
in {
  sops.secrets.walther-password.neededForUsers = true;
  users.mutableUsers = false;

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      ${main-user} = import ../../../home/walther/home.nix;
    };
  };

  users.users.${main-user} = {
    isNormalUser = true;
    # password = "123";
    hashedPasswordFile = config.sops.secrets.walther-password.path;
    extraGroups = [
      "networkmanager"
      "audio"
      "wheel"
    ];

    shell = pkgs.fish;
  };

  users.users.root = {
    password = "123";
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
