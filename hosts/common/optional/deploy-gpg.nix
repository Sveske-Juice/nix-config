# inspiration: https://github.com/mateusauler/nixos-config
{
  sopsKeyPath ? "gpg/key",
  sopsPasswdPath ? "gpg/passwd",
  pkgs,
  config,
  ...
}:
let
  gnupgphome = "${config.hostSpec.home}/.gnupg";
  getSecretKeyIDs = "$(${pkgs.gnupg}/bin/gpg --list-secret-keys --keyid-format LONG | ${pkgs.gawk}/bin/awk '/sec/{if (match($0, /([0-9A-F]{16,})/, m)) print m[1]}')";
in
{
  # Change to user's sops file if not main key
  sops.secrets."${sopsKeyPath}" = {
    owner = config.hostSpec.username;
    sopsFile = ../../../secrets/shared.yaml;
  };

  sops.secrets."${sopsPasswdPath}" = {
    owner = config.hostSpec.username;
    sopsFile = ../../../secrets/shared.yaml;
  };

  systemd.services.deploy-gpg = {
    description = "Deploy a user's PGP key";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = config.hostSpec.username;
      ExecStart = "${pkgs.writeShellScript "deploy-gpg.sh" # bash
        ''
          if [ -s ${config.sops.secrets."${sopsKeyPath}".path} ]; then
            mkdir -p ${gnupgphome} -m "0700"
            ${pkgs.gnupg}/bin/gpg --pinentry-mode loopback --import ${
              config.sops.secrets."${sopsKeyPath}".path
            }

            # Set passwd
            if [ -s ${config.sops.secrets."${sopsPasswdPath}".path} ]; then
              secretKeyId=${getSecretKeyIDs}
              for key in ''${secretKeyId[@]}
              do
                cat "${config.sops.secrets."${sopsPasswdPath}".path}" | ${pkgs.gnupg}/bin/gpg --batch --passphrase-fd 0 --pinentry-mode loopback --edit-key $key passwd quit
              done
            fi
          fi
        ''
      }";
    };
  };

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    enableSSHSupport = true;
  };
}
