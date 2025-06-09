{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = null;
      PermitRootLogin = "no";
    };
    banner = "";

    # Generate RSA key. Ed25519 key comes from sops
    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
    ];

    allowSFTP = true;
  };

  programs.ssh.startAgent = true;
  programs.mtr.enable = true;
  programs.gnupg.agent.enable = true;
}
