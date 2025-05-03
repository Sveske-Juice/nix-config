{...}: {
  users.groups.sftponly = {};
  users.users.deprivedslave = {
    home = "/srv/ssh/jail/deprived";
    createHome = false;
    homeMode = "755";
    shell = "/run/current-system/sw/bin/nologin";
    group = "sftponly";
    isNormalUser = true;
    useDefaultShell = false;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../keys/id_sveske.pub)
      (builtins.readFile ../../keys/id_redux.pub)
      (builtins.readFile ../../keys/id_walther.pub)
      (builtins.readFile ../../keys/id_botserver.pub)
      (builtins.readFile ../../keys/id_botalex.pub)
    ];
  };
  system.activationScripts."createslavehome" = ''
    mkdir -p /srv/ssh/jail/deprived/assets
    chown root:root /srv/ssh/jail/deprived
    chmod -R 775 /srv/ssh/jail/deprived/assets
    chgrp -R sftponly /srv/ssh/jail/deprived/assets
  '';

  services.openssh.extraConfig = ''
    Match group sftponly
     ChrootDirectory %h
     X11Forwarding no
     AllowTcpForwarding no
     PasswordAuthentication yes
     ForceCommand internal-sftp
  '';
}
