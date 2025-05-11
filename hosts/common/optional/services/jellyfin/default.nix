{pkgs, ...}: let
  # configDir = "jellyfin"; # Relative from /etc/
  # configDirAbsolute = "/etc/${configDir}";
  group = "data";
in {
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = group;
    # configDir = configDirAbsolute;
  };

  # AMD VA-API and VDPAU should work out of the box with mesa
  hardware.graphics.enable = true;

  # Configuration
  # We could declare settings declaratively like this, but i will just use the GUI
  # environment."${configDir}/system.xml".text = builtins.readFile ./system.xml;
  # environment."${configDir}/network.xml".text = builtins.readFile ./network.xml;

  users.users.jellyfin.extraGroups = ["video" "render"];

  # NGINX
  services.nginx.virtualHosts."jellyfin.casdnas.deprived.dev" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      # proxyPass = "http://127.0.0.1:${toString 8096}";
      # proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 256M;

        # Websocket support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;

        proxy_pass_request_headers on;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $http_host;

        # Disable buffering when the nginx proxy gets very resource heavy upon streaming
        proxy_buffering off;

        proxy_pass http://127.0.0.1:8096;
      '';
    };

    locations."/socket" = {
      extraConfig = ''
        # Proxy Jellyfin Websockets traffic
        proxy_pass http://127.0.0.1:8096;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
      '';
    };
  };
}
