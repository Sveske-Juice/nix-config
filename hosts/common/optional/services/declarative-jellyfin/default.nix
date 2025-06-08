{
  pkgs,
  inputs,
  config,
  ...
}: let
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
  ];

  # Set `HashedPasswordFile` foreach user
  hashedPasswordDefinitions = builtins.listToAttrs (map (user: {
      name = "${user}";
      value = {HashedPasswordFile = config.sops.secrets."jellyfin/${user}".path;};
    })
    jellyfinUsers);
in {
  imports = [
    inputs.declarative-jellyfin.nixosModules.default
  ];


  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  # AMD VA-API and VDPAU should work out of the box with mesa
  hardware.graphics.enable = true;
  users.users.${config.services.jellyfin.user}.extraGroups = ["video" "render"];

  # SOPS -- Extract secrets foreach user
  sops.secrets = builtins.listToAttrs (map (user: {
      name = "jellyfin/${user}";
      value = {
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
    })
    jellyfinUsers) // {
    "jellyfin/jellyseerr-api-key" = {};
  };

  # DECLARATIVE-JELLYFIN
  services.declarative-jellyfin = {
    enable = true;
    inherit group;
    system = {
      IsStartupWizardCompleted = true;
      TrickplayOptions = {
        EnableHwAcceleration = true;
        EnableHwEncoding = true;
      };
      UICulture = "da"; # danish
    };
    Users =
      pkgs.lib.recursiveUpdate hashedPasswordDefinitions
      {
        CasdAdmin = {
          Mutable = false;
          Permissions = {
            IsAdministrator = true;
          };
        };
        Benjamin = {
          Mutable = false;
          Permissions = {
            IsAdministrator = true;
          };
        };
        "gags5" = {
          Permissions.EnableAllFolders = false;
          Preferences.EnabledLibraries = [ "Movies" "Shows" ];
        };
        "guacamole" = {
          Permissions.EnableAllFolders = false;
          Preferences.EnabledLibraries = [ "Movies" "Shows" ];
        };
        "alex" = {
          Permissions.EnableAllFolders = false;
          Preferences.EnabledLibraries = [ "Movies" "Shows" ];
        };
      };
    libraries = {
      "Movies" = {
        Enabled = true;
        ContentType = "movies";
        PathInfos = ["/data/Movies"];
        EnableChapterImageExtraction = true;
        ExtractChapterImagesDuringLibraryScan = true;
        EnableTrickplayImageExtraction = true;
        ExtractTrickplayImagesDuringLibraryScan = true;
        SaveTrickplayWithMedia = true;
      };
      "Shows" = {
        Enabled = true;
        ContentType = "tvshows";
        PathInfos = ["/data/Shows"];
        EnableChapterImageExtraction = true;
        ExtractChapterImagesDuringLibraryScan = true;
        EnableTrickplayImageExtraction = true;
        ExtractTrickplayImagesDuringLibraryScan = true;
        SaveTrickplayWithMedia = true;
      };
      "Photos" = {
        Enabled = true;
        ContentType = "homevideos";
        PathInfos = ["/data/Photos"];
        EnableChapterImageExtraction = true;
        ExtractChapterImagesDuringLibraryScan = true;
        EnableTrickplayImageExtraction = true;
        ExtractTrickplayImagesDuringLibraryScan = true;
        SaveTrickplayWithMedia = true;
      };
    };
    encoding = {
      EnableHardwareEncoding = true;
      HardwareAccelerationType = "vaapi";
      EnableDecodingColorDepth10Hevc = true;
      AllowHevcEncoding = true;
      AllowAv1Encoding = true;
      HardwareDecodingCodecs = [
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
