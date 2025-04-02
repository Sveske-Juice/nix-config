{port ? throw "no port", ...}: let
  user = "jackett";
  group = "jackett";
in {
  services.jackett = {
    enable = true;

    user = user;
    group = group;
    port = port;

    openFirewall = true;
  };
}
