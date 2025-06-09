{ ... }:
let
  user = "radarr";
  group = "data";
in
{
  users.groups.media.members = [ user ];

  services.radarr = {
    enable = true;

    user = user;
    group = group;

    settings = {
      log.analyticsEnabled = false;
    };

    openFirewall = true;
  };
}
