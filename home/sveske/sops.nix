{
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/home/sveske/.config/sops/age/keys.txt";
    
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    secrets = {
    };
  };
}
