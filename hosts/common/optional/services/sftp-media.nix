{ ... }:
let
  jailDir = "/srv/ssh/jail/media";
in
{
  system.activationScripts."createmediaslavehome" = ''
    mkdir -p ${jailDir}/data
    chown root:root ${jailDir}
    chmod 755 ${jailDir}
  '';

  # Bind mount /data to mediaslave jail dir
  fileSystems."${jailDir}/data" = {
    device = "/data";
    fsType = "non";
    options = [ "bind" "ro" ];
  };
  # systemd.mounts = [
  #   {
  #     name = "srv-chroot_data.mount";
  #     what = "/data";
  #     where = jailDir;
  #     type = "none";
  #     options = [
  #       "bind"
  #       "ro"
  #     ];
  #   }
  # ];

  users.users.mediaslave = {
    createHome = false;
    shell = "/run/current-system/sw/bin/nologin";
    group = "data";
    isNormalUser = true;
    useDefaultShell = false;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../keys/id_sveske.pub)
      (builtins.readFile ../../keys/id_redux.pub)
      (builtins.readFile ../../keys/id_walther.pub)
      (builtins.readFile ../../keys/id_botserver.pub)
      (builtins.readFile ../../keys/id_botalex.pub)
      (builtins.readFile ../../keys/id_botlap.pub)
      (builtins.readFile ../../keys/id_pixel8a.pub)
      (builtins.readFile ../../keys/id_botmain.pub)
      (builtins.readFile ../../keys/id_botlap_nixos.pub)
    ];
  };

  # SFTP read only
  services.openssh.extraConfig = ''
    Match User mediaslave
     ChrootDirectory ${jailDir}
     X11Forwarding no
     AllowTcpForwarding no
     PasswordAuthentication no
     ForceCommand internal-sftp -R
  '';
}
