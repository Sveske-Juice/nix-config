{pkgs, ...}: let
  port = 56565;
in {
  imports = [
    ./gitea-actions-runner.nix
  ];
  services.forgejo = {
    enable = true;

    lfs.enable = true;
    database.type = "postgres";

    settings = {
      DEFAULT = {
        APP_NAME = "Deprived dev's git";
      };

      repository = {
        ENABLE_PUSH_CREATE_USER = true;
      };

      server = {
        DOMAIN = "git.deprived.dev";
        HTTP_PORT = port;
        ROOT_URL = "https://git.deprived.dev";
      };

      security.REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/24";

      service.DISABLE_REGISTRATION = true;
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "https://code.forgejo.org";
      };
      federation.ENABLED = false;
    };
  };
}
