{
  inputs,
  config,
  ...
}:
let
    installTmpAgeKeyPath = "/keys.txt";
    postInstallAgeKeyPath = "/var/lib/sops-nix/key.txt";
    useTmpKey = builtins.pathExists /keys.txt;
in
builtins.trace ("Does temp key exist? " + (if useTmpKey then "true" else "false") + " Path: " + installTmpAgeKeyPath)
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../../secrets.yaml;
    validateSopsFiles = false;
    age = if useTmpKey then {
        keyFile = installTmpAgeKeyPath;
    }
    else {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = postInstallAgeKeyPath;
        generateKey = true;
    };

    secrets = {
        # "private_host_keys/waltherbox" = {
        #     owner = "root";
        #     group = "root";
        #     path = "/etc/ssh/ssh_host_ed25519_key";
        # };
    };
  };
}
