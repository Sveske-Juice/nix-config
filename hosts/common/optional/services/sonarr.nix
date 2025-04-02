{...}: let
  user = "sonarr";
  group = "sonarr";
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
