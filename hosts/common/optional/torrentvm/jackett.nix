{
  port ? throw "no port",
  ...
}:
let
  user = "jackett";
  group = "data";
in
{
  services.jackett = {
    enable = true;

    # user = user;
    group = group;
    inherit port;
    dataDir = "/mnt/jackett";

    openFirewall = true;
  };

  # systemd.services.jackett.serviceConfig.ExecStartPre = ''/bin/sh -c "chown -R ${user}:${group} /mnt/jackett"'';
}
