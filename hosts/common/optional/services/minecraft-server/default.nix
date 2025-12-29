{inputs, pkgs, config, ...}: let
  cvpl-port = 25565;
  cvpl-rcon-port = 25575;
  alexworld-port = 25566;
  alexworld-rcon-port = 25576;
in {
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  sops.secrets."minecraft/mc-cvpl/rcon-password".owner = config.services.minecraft-servers.user;
  sops.secrets."minecraft/mc-cvpl/motd".owner = config.services.minecraft-servers.user;
  sops.secrets."minecraft/mc-cvpl/name".owner = config.services.minecraft-servers.user;

  sops.secrets."minecraft/mc-cvpl/ops/op1/name".owner = config.services.minecraft-servers.user;
  sops.secrets."minecraft/mc-cvpl/ops/op1/uuid".owner = config.services.minecraft-servers.user;

  sops.secrets."minecraft/alex-world/rcon-password".owner = config.services.minecraft-servers.user;
  sops.secrets."minecraft/alex-world/ops/op1/name".owner = config.services.minecraft-servers.user;
  sops.secrets."minecraft/alex-world/ops/op1/uuid".owner = config.services.minecraft-servers.user;
  sops.secrets."minecraft/alex-world/ops/op2/name".owner = config.services.minecraft-servers.user;
  sops.secrets."minecraft/alex-world/ops/op2/uuid".owner = config.services.minecraft-servers.user;

  # TODO: automate this
  sops.templates."alex-world-ops" = {
    owner = config.services.minecraft-servers.user;
    content = ''
      [
        {
          "uuid": "${config.sops.placeholder."minecraft/alex-world/ops/op1/uuid"}",
          "name": "${config.sops.placeholder."minecraft/alex-world/ops/op1/name"}",
          "level": 4,
          "bypassesPlayerLimit": true
        },
        {
          "uuid": "${config.sops.placeholder."minecraft/alex-world/ops/op2/uuid"}",
          "name": "${config.sops.placeholder."minecraft/alex-world/ops/op2/name"}",
          "level": 4,
          "bypassesPlayerLimit": true
        },
      ]
    '';
  };

  sops.templates."alex-world-server-properties" = {
    owner = config.services.minecraft-servers.user;
    content = ''
      difficulty=hard
      gamemode=survival
      rcon.port=${toString alexworld-rcon-port}
      rcon.password=${config.sops.placeholder."minecraft/alex-world/rcon-password"}
    '';
  };

  sops.templates."mc-cvpl-ops" = {
    owner = config.services.minecraft-servers.user;
    content = ''
      [
        {
          "uuid": "${config.sops.placeholder."minecraft/mc-cvpl/ops/op1/uuid"}",
          "name": "${config.sops.placeholder."minecraft/mc-cvpl/ops/op1/name"}",
          "level": 4,
          "bypassesPlayerLimit": true
        },
      ]
    '';
  };

  sops.templates."mc-cvpl-server-properties" = {
    owner = config.services.minecraft-servers.user;
    content = ''
      accepts-transfers=false
      allow-flight=false
      broadcast-console-to-ops=true
      broadcast-rcon-to-ops=true
      bug-report-link=
      difficulty=hard
      enable-code-of-conduct=false
      enable-jmx-monitoring=false
      enable-query=false
      enable-rcon=true
      enable-status=true
      enforce-secure-profile=true
      enforce-whitelist=false
      entity-broadcast-range-percentage=100
      force-gamemode=false
      function-permission-level=2
      gamemode=survival
      generate-structures=true
      generator-settings={}
      hardcore=false
      hide-online-players=false
      initial-disabled-packs=
      initial-enabled-packs=vanilla,bigglobe,fabric-convention-tags-v2
      level-name=${config.sops.placeholder."minecraft/mc-cvpl/name"}
      level-seed=
      level-type=bigglobe:bigglobe
      log-ips=true
      max-chained-neighbor-updates=1000000
      max-players=69
      max-tick-time=60000
      max-world-size=29999984
      motd=${config.sops.placeholder."minecraft/mc-cvpl/motd"}
      network-compression-threshold=256
      online-mode=true
      op-permission-level=4
      pause-when-empty-seconds=60
      player-idle-timeout=0
      prevent-proxy-connections=false
      query.port=${toString cvpl-port}
      rate-limit=0
      rcon.password=${config.sops.placeholder."minecraft/mc-cvpl/rcon-password"}
      rcon.port=${toString cvpl-rcon-port}
      region-file-compression=deflate
      require-resource-pack=false
      resource-pack=
      resource-pack-id=
      resource-pack-prompt=
      resource-pack-sha1=
      server-ip=
      server-port=${toString cvpl-port}
      simulation-distance=10
      spawn-protection=16
      status-heartbeat-interval=0
      sync-chunk-writes=true
      text-filtering-config=
      text-filtering-version=0
      use-native-transport=true
      view-distance=10
      white-list=false
    '';
  };

  networking.firewall.allowedTCPPorts = [
    cvpl-port
    cvpl-rcon-port

    alexworld-port
    alexworld-rcon-port
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.mc-cvpl = {
      enable = true;
      jvmOpts = "-Xmx18G -Xms2G";
      package = pkgs.fabricServers.fabric-1_21_11;

      serverProperties.server-port = cvpl-port;

      # mods
      symlinks = {
        "server.properties" = config.sops.templates."mc-cvpl-server-properties".path;
        "server-icon.png" = ./server-icon.png;
        "ops.json" = config.sops.templates."mc-cvpl-ops".path;

        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Fabric-API = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/gB6TkYEJ/fabric-api-0.140.2%2B1.21.11.jar";
              sha256 = "sha256-t8RYO3/EihF5gsxZuizBDFO3K+zQHSXkAnCUgSb4QyE=";
            };
            Satin-API = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fRbqPLg4/versions/Tq9qJzQz/satin-2.0.0.jar";
              sha256 = "sha256-PmdHvzM6pn4h7PlsQEsAleRgRTicHV/El0EvZ+Y+oTY=";
            };
            BigGlobe = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/xsng1aJf/versions/ftbv5Ksq/Big%20Globe-5.2.1-MC1.21.11.jar";
              sha256 = "sha256-zMATtnYAsujuMMF07gIksL7FsPJ7Cu1131Kshfw4qBg=";
            };
            Chunky = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/1CpEkmcD/Chunky-Fabric-1.4.55.jar";
              sha256 = "sha256-M8vZvODjNmhRxLWYYQQzNOt8GJIkjx7xFAO77bR2vRU=";
            };
            Lithium = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/gl30uZvp/lithium-fabric-0.21.2%2Bmc1.21.11.jar";
              sha256 = "sha256-MQZjnHPuI/RL++Xl56gVTf460P1ISR5KhXZ1mO17Bzk=";
            };
            C2ME = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/VSNURh3q/versions/lYSxkbzC/c2me-fabric-mc1.21.11-0.3.6%2Brc.1.0.jar";
              sha256 = "sha256-pcvM0y05Iul3OPrHHMZ9k4EDT5vwj/0B9gjEIA/R/b8=";
            };
            DH = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/uCdwusMi/versions/GT3Bm3GN/DistantHorizons-2.4.5-b-1.21.11-fabric-neoforge.jar";
              sha256 = "sha256-dpTHoX5V9b7yG0VsIqKxxOSAYLN0Z97itx1MEuWGvD8=";
            };
          }
        );
      };
    };

    servers.alex-world = {
      enable = true;
      jvmOpts = "-Xmx6G -Xms1G";
      package = pkgs.fabricServers.fabric-1_21_4;

      serverProperties.server-port = alexworld-port;

      symlinks = {
        "server.properties" = config.sops.templates."alex-world-server-properties".path;
        "ops.json" = config.sops.templates."alex-world-ops".path;

        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Fabric-API = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/p96k10UR/fabric-api-0.119.4%2B1.21.4.jar";
              sha256 = "sha256-0YO6y4RRZ/CSZML5AyK37P/ogm3r2m9g5ZeIkmS+9K8=";
            };
            DH = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/uCdwusMi/versions/NhMXwQCV/DistantHorizons-2.4.5-b-1.21.4-fabric-neoforge.jar";
              sha256 = "sha256-qk4c3J12Kb/+C1g0wiahEwhioVgLb4f1EI2tAQdhPX0=";
            };
            Chunky = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/VkAgASL1/Chunky-Fabric-1.4.27.jar";
              sha256 = "sha256-A8kKcLIzQWvZZziUm+kJ0eytrHQ/fBVZQ18uQXN9Qf0=";
            };
            C2ME = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/VSNURh3q/versions/EzvMx6b2/c2me-fabric-mc1.21.4-0.3.1.3.0.jar";
              sha256 = "sha256-i3r6jdtLW10kpZ70s+OvAxchpVdrRZ+6O06AvR99MZE=";
            };
          }
        );
      };
    };
  };
}
