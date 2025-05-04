{
  pkgs,
  config,
  ...
}: let
  allowedBranches = ["main" "dev"];
  srcUrl = "https://git.deprived.dev/DeprivedDevs/deprived-main-website.git";
in {
  users.groups.www = {};

  users.users.deprivedbuilder = {
    createHome = true;
    group = "www";
    isNormalUser = true;
    password = "123";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8f0teq3MqGLflBZ+cwXRquTY/WEWRRewJjTjrx1rkb builder@server"
    ];
  };

  security.sudo.extraRules = [
    {
      users = ["deprivedbuilder"];
      commands = pkgs.lib.lists.forEach allowedBranches (
        branch: {
          command = "/run/current-system/sw/bin/systemctl start build-deprived-website-${branch}";
          options = ["SETENV" "NOPASSWD"];
        }
      );
    }
  ];

  system.activationScripts."www dir" = ''
    mkdir -p /var/www/
    # Create directory for each branch of deprived website
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.lists.forEach allowedBranches (branch: "mkdir -p /var/www/deprived/${branch}"))}
    chown root:www -R /var/www
    chmod 775 -R /var/www
  '';

  systemd.services =
    pkgs.lib.attrsets.genAttrs (pkgs.lib.lists.forEach allowedBranches (branch: "build-deprived-website-${branch}"))
    (serviceName: {
      enable = true;
      wants = ["network-online.target"];
      after = ["network-online.target"];
      path = with pkgs; [
        bash
        nodejs
      ];

      serviceConfig = {
        Type = "oneshot";
        User = "deprivedbuilder";
        Group = "www";
        StandardOutput = "file:/home/deprivedbuilder/latest_build.log";
        StandardError = "inherit";

        RemainAfterExit = false;
      };

      script =
        /*
        bash
        */
        ''
          # Clear log
          truncate -s 0 /home/deprivedbuilder/latest_build.log

          branch=$(echo "${serviceName}" | cut -d'-' -f4)
          echo "Building branch: $branch"

          # Build project in temp dir and move later
          tmpdir=$(mktemp -d)
          trap "rm -rf $tmpdir" exit
          cd $tmpdir

          mkdir repo
          cd repo
          ${pkgs.git}/bin/git clone ${srcUrl} .
          ${pkgs.git}/bin/git checkout "$branch"

          HOME=$(mktemp -d) ${pkgs.nodejs}/bin/npm ci --loglevel=verbose
          ${pkgs.nodejs}/bin/npx ./node_modules/vite build

          # Move result
          cp -r build/* "/var/www/deprived/$branch"
        '';
    });
  services.nginx.virtualHosts."deprived.dev" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/deprived/main";
  };
}
