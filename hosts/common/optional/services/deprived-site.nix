{ pkgs, config, ... }:
let
  mainBranch = "main";
  allowedBranches = [
    "main"
    "dev"
  ];
  srcUrl = "ssh://forgejo@git.deprived.dev/DeprivedDevs/deprived-main-website.git";
in
{
  users.groups.www = { };

  users.users.deprivedbuilder = {
    createHome = true;
    group = "www";
    isNormalUser = true;
    password = "123";
    # So that the git action can signal to rebuild over ssh
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8f0teq3MqGLflBZ+cwXRquTY/WEWRRewJjTjrx1rkb builder@server"
    ];
  };

  sops.secrets."deprivedbuilder-ssh-key" = {
    owner = "deprivedbuilder";
    sopsFile = ../../../../secrets/shared.yaml;
    path = "/home/deprivedbuilder/.ssh/id_ed25519";
  };

  # Deploy deprivedbuilder's ssh key for access to private git repo
  system.activationScripts.genBuilderPublicSSHKey = {
    text =
      let
        keyPath = "/home/deprivedbuilder/.ssh/id_ed25519";
        # bash
      in
      ''
        mkdir -p "/home/deprivedbuilder/.ssh"

        # Make sure there is a private key
        if [ -f "${keyPath}" ]; then
          ${pkgs.openssh}/bin/ssh-keygen -y -f "${keyPath}" > "${keyPath}.pub"
        fi
        chown -R deprivedbuilder "/home/deprivedbuilder/.ssh"
      '';
  };

  # No need for auth to rebuild site
  security.sudo.extraRules = [
    {
      users = [ "deprivedbuilder" ];
      commands = pkgs.lib.lists.forEach allowedBranches (branch: {
        command = "/run/current-system/sw/bin/systemctl start build-deprived-website-${branch}";
        options = [
          "SETENV"
          "NOPASSWD"
        ];
      });
    }
  ];

  system.activationScripts."www dir" = ''
    mkdir -p /var/www/
    # Create directory for each branch of deprived website
    ${pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.lists.forEach allowedBranches (branch: "mkdir -p /var/www/deprived/${branch}")
    )}
    chown root:www -R /var/www
    chmod 775 -R /var/www
  '';

  systemd.services =
    pkgs.lib.attrsets.genAttrs
      (pkgs.lib.lists.forEach allowedBranches (branch: "build-deprived-website-${branch}"))
      (serviceName: {
        enable = true;
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
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

        # Rebuild script foreach branch
        script =
          # bash
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
            GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=accept-new" ${pkgs.git}/bin/git clone ${srcUrl} .
            ${pkgs.git}/bin/git checkout "$branch"

            HOME=$(mktemp -d) ${pkgs.nodejs}/bin/npm i --loglevel=verbose
            HOME=$(mktemp -d) ${pkgs.nodejs}/bin/npm ci --loglevel=verbose
            ${pkgs.nodejs}/bin/npx ./node_modules/vite build

            # Move result
            cp -r build/* "/var/www/deprived/$branch"
          '';
      });

  # subdomain foreach other branch
  services.nginx.virtualHosts =
    (pkgs.lib.attrsets.mapAttrs'
      (branch: serviceCfg: pkgs.lib.attrsets.nameValuePair (branch + ".deprived.dev") serviceCfg)
      (
        pkgs.lib.attrsets.genAttrs (pkgs.lib.lists.remove mainBranch allowedBranches) (branch: {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            root = "/var/www/deprived/${branch}";
            extraConfig = ''
              # Remove trailing slash
              rewrite ^/(.*)/$ /$1 permanent;
              try_files $uri $uri.html $uri/index.html =404;
            '';
          };
          locations."/assets" = {
            root = "/srv/ssh/jail/deprived";
            extraConfig = ''
              index index.html;
              autoindex on;
              autoindex_exact_size on;
              autoindex_localtime on;
            '';
          };
        })
      )
    )
    // {
      # Main version
      "deprived.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/deprived/${mainBranch}";
          extraConfig = ''
            # Remove trailing slash
            rewrite ^/(.*)/$ /$1 permanent;
            try_files $uri $uri.html $uri/index.html =404;
          '';
        };
        locations."/assets" = {
          root = "/srv/ssh/jail/deprived";
          extraConfig = ''
            index index.html;
            autoindex on;
            autoindex_exact_size on;
            autoindex_localtime on;
          '';
        };
      };
    };
}
