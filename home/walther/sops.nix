{inputs, config, ...}:
let
  homeDir = config.home.homeDirectory;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";

    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    secrets = {
      "private_keys/walther" = {
        path = "${homeDir}/.ssh/id_ed25519";
      };
    };
  };
}
