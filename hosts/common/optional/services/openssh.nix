{...}: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = null;
      PermitRootLogin = "no";
    };
    banner = '''';

    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
    ];
  };

  programs.ssh.startAgent = true;
  programs.mtr.enable = true;
  programs.gnupg.agent.enable = true;
}
