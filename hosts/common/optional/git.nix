{
  pkgs,
  config,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    config = {
      user = {
        name = config.hostSpec.handle;
        email = config.hostSpec.email;
      };
      safe.directory = [
        "/etc/nixos"
      ];
    };
  };
}
