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
    "guacamole"
    "gags5"
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

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = group;
  };

  # AMD VA-API and VDPAU should work out of the box with mesa
  hardware.graphics.enable = true;
  users.users.jellyfin.extraGroups = ["video" "render"];

  # SOPS -- Extract secrets foreach user
  sops.secrets = builtins.listToAttrs (map (user: {
      name = "jellyfin/${user}";
      value = {
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
    })
    jellyfinUsers);

  system.activationScripts.create-db.deps = ["setupSecrets"];

  # DECLARATIVE-JELLYFIN
  services.declarative-jellyfin = {
    enable = true;
    system = {
      IsStartupWizardCompleted = true;
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
      };
    libraries = {
      "Movies" = {
        Enabled = true;
        PathInfos = ["/data/Movies"];
        EnableChapterImageExtraction = true;
        ExtractChapterImagesDuringLibraryScan = true;
        EnableTrickplayImageExtraction = true;
        ExtractTrickplayImagesDuringLibraryScan = true;
        SaveTrickplayWithMedia = true;
      };
      "Shows" = {
        Enabled = true;
        PathInfos = ["/data/Shows"];
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
