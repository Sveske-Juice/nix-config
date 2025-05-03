{...}: let
  user = "sonarr";
  group = "data";
in {
  users.groups.media.members = [user];

  services.sonarr = {
    enable = true;

    user = user;
    group = group;

    settings = {
      log.analyticsEnabled = false;
    };
    openFirewall = true;
  };
}
