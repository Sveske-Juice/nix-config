{inputs, config, hostSpec, ...}:
let
  homeDir = config.home.homeDirectory;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    # FIXME: maybe /var/lib...?
    age.keyFile = "${hostSpec.home}/.config/sops/age/key.txt";

    defaultSopsFile = ../../secrets/${hostSpec.hostName}.yaml;
    validateSopsFiles = false;

    secrets = {
    };
  };
}
