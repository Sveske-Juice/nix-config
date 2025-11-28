{ config, ... }:
{
  imports = [ ./core.nix ];
  system.activationScripts.createsyncdir = ''
    install -Dm 770 -o ${config.services.syncthing.user} -g ${config.services.syncthing.group} /sync
  '';

  services.syncthing = {
    dataDir = "/sync";
    user = "syncthing";
    group = "data";
    settings = {
      gui = {
        user = config.hostSpec.username;
        password = "$2b$05$I0ofnse7HEEVqyvgjwD3FOLGiXHbobSUURvud3iR3z6LKi461puyS";
      };
    };
  };
}
