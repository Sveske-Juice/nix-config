{
  pkgs,
  inputs,
  config,
  ...
}:
let
  group = "data";
  jellyfinUsers = [
    "CasdAdmin"
    "Benjamin"
    "Stuen"
    "Alexander"
    "Christopher"
    "Kathrine"
    "gags5"
    "guacamole"
    "alex"
    "rams"
  ];

  # Set `HashedPasswordFile` foreach user
  hashedPasswordDefinitions = builtins.listToAttrs (
    map (user: {
      name = "${user}";
      value = {
        hashedPasswordFile = config.sops.secrets."jellyfin/${user}".path;
      };
    }) jellyfinUsers
  );
in
{
  users.groups.data = { };
  imports = [ inputs.declarative-jellyfin.nixosModules.default ];

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  # AMD VA-API and VDPAU should work out of the box with mesa
  hardware.graphics.enable = true;
  users.users.${config.services.jellyfin.user}.extraGroups = [
    "video"
    "render"
  ];

  # SOPS -- Extract secrets foreach user
  sops.secrets =
    builtins.listToAttrs (
      map (user: {
        name = "jellyfin/${user}";
        value = {
          owner = config.services.jellyfin.user;
          group = config.services.jellyfin.group;
        };
      }) jellyfinUsers
    )
    // {
      "jellyfin/jellyseerr-api-key" = { };
    };

  # DECLARATIVE-JELLYFIN
  services.declarative-jellyfin = {
    enable = true;
    inherit group;
    serverId = "50549af6c9344827a98a0dc85e0a1c97";
    system = {
      isStartupWizardCompleted = true;
      trickplayOptions = {
        enableHwAcceleration = true;
        enableHwEncoding = true;
      };
      UICulture = "da"; # danish
    };
    users = pkgs.lib.recursiveUpdate hashedPasswordDefinitions {
      CasdAdmin = {
        mutable = false;
        permissions = {
          isAdministrator = true;
        };
      };
      Benjamin = {
        mutable = false;
        permissions = {
          isAdministrator = true;
        };
      };
      "gags5" = {
        permissions.enableAllFolders = false;
        preferences.enabledLibraries = [
          "Movies"
          "Shows"
        ];
      };
      "rams" = {
        permissions.enableAllFolders = false;
        preferences.enabledLibraries = [
          "Movies"
          "Shows"
        ];
      };
      "guacamole" = {
        permissions.enableAllFolders = false;
        preferences.enabledLibraries = [
          "Movies"
          "Shows"
        ];
      };
      "alex" = {
        permissions.enableAllFolders = false;
        preferences.enabledLibraries = [
          "Movies"
          "Shows"
        ];
      };
    };
    libraries = {
      "Movies" = {
        enabled = true;
        contentType = "movies";
        pathInfos = [ "/data/Movies" ];
        enableChapterImageExtraction = true;
        extractChapterImagesDuringLibraryScan = true;
        enableTrickplayImageExtraction = true;
        extractTrickplayImagesDuringLibraryScan = true;
        saveTrickplayWithMedia = true;
      };
      "Shows" = {
        enabled = true;
        contentType = "tvshows";
        pathInfos = [ "/data/Shows" ];
        enableChapterImageExtraction = true;
        extractChapterImagesDuringLibraryScan = true;
        enableTrickplayImageExtraction = true;
        extractTrickplayImagesDuringLibraryScan = true;
        saveTrickplayWithMedia = true;
      };
      "Photos" = {
        enabled = true;
        contentType = "homevideos";
        pathInfos = [ "/data/Photos" ];
        enableChapterImageExtraction = true;
        extractChapterImagesDuringLibraryScan = true;
        enableTrickplayImageExtraction = true;
        extractTrickplayImagesDuringLibraryScan = true;
        saveTrickplayWithMedia = true;
      };
    };
    encoding = {
      enableHardwareEncoding = true;
      hardwareAccelerationType = "vaapi";
      enableDecodingColorDepth10Hevc = true;
      allowHevcEncoding = true;
      allowAv1Encoding = true;
      hardwareDecodingCodecs = [
        "h264"
        "hevc"
        "mpeg2video"
        "vc1"
        "vp9"
        "av1"
      ];
    };
    apikeys = {
      Jellyseerr.keyPath = config.sops.secrets."jellyfin/jellyseerr-api-key".path;
    };
  };

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
