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
      "private_keys/sveske" = {
        path = "/home/sveske/.ssh/id_ed25519";
      };
      "public_keys/sveske" = {
        path = "/home/sveske/.ssh/id_ed25519.pub";
      };
    };
  };
}
