{ ... }:
let
  jailDir = "/srv/ssh/jail/deprived";
in
{
  users.groups.sftponly = { };
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
    mkdir -p ${jailDir}/assets
    chown root:root ${jailDir}
    chmod -R 775 ${jailDir}/assets
    chgrp -R sftponly ${jailDir}/assets
  '';

  services.openssh.extraConfig = ''
    Match group sftponly
     ChrootDirectory %h
     X11Forwarding no
     AllowTcpForwarding no
     PasswordAuthentication yes
     ForceCommand internal-sftp
  '';

  # NGINX
  # services.nginx.virtualHosts."deprived.dev" = {
  #   forceSSL = true;
  #   enableACME = true;
  #   root = "${jailDir}/assets";
  #   extraConfig = ''
  #     # Remove trailing slash
  #     rewrite ^/(.*)/$ /$1 permanent;
  #     try_files $uri $uri.html $uri/index.html =404;
  #   '';
  # };
}
