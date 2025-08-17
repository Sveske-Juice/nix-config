{ lib, pkgs, ... }:
{
  users.groups.sftponly = { };
  users.users.zhenborgslave = {
    home = "/srv/ssh/jail/zhenborgslave";
    createHome = true;
    homeMode = "755";
    # shell = "/run/current-system/sw/bin/nologin";
    shell = "/run/current-system/sw/bin/bash";
    isNormalUser = true;
    useDefaultShell = false;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../keys/id_botserver.pub)
      (builtins.readFile ../../keys/id_botserverroot.pub)
      (builtins.readFile ../../keys/id_redux.pub)
    ];
  };
  environment.systemPackages = [
    pkgs.borgbackup
  ];
}
