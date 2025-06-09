{ config, ... }:
{
  # Extract secret
  sops.secrets."msmtp/gmail" = { };

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      port = 465;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
      tls = "on";
      auth = "login";
      tls_starttls = "off";
    };
    accounts = {
      default = {
        host = "smtp.gmail.com";
        passwordeval = "cat ${config.sops.secrets."msmtp/gmail".path}";
        user = config.hostSpec.email;
        from = "${config.hostSpec.username}@${config.hostSpec.hostName}.org";
      };
    };
  };

  # Re-direct all mail to root to primary user's email
  environment.etc = {
    "aliases" = {
      text = ''
        root: ${config.hostSpec.email}
      '';
      mode = "0644";
    };
  };
}
