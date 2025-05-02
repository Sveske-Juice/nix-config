{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./docker.nix
  ];

  sops.secrets.forgejo-registration-token = {
    owner = config.services.forgejo.user;
    group = config.services.forgejo.group;
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances = {
      kartoffel = {
        enable = true;
        name = "kartoffel";
        url = "http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}";
        tokenFile = config.sops.secrets.forgejo-registration-token.path;
        labels = [
          "native:host"
        ];
        hostPackages = pkgs.lib.attrValues {
          inherit
            (pkgs)
            nix
            nodejs
            git
            bash
            ripgrep
            openssh
            ;
        };
        settings = {
          log.level = "info";
          runner = {
            file = ".runner";
            capacity = 2;
            timeout = "3h";
            insecure = false;
            fetch_timeout = "5s";
            fetch_interval = "2s";
          };
        };
      };
    };
  };

  system.activationScripts."make-gitea-runner-dir" = pkgs.lib.stringAfter ["var"] ''
    mkdir -p /var/lib/gitea-runner/
  '';
}
