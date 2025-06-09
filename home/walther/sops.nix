{ inputs, hostSpec, ... }:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${hostSpec.home}/.config/sops/age/key.txt";

    defaultSopsFile = ../../secrets/${hostSpec.hostName}.yaml;
    validateSopsFiles = false;

    secrets = { };
  };
}
