{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
    age
  ];

  sops = {
    defaultSopsFile = ../../../secrets/${config.hostSpec.hostName}.yaml;
    validateSopsFiles = false;

    age = {
      # Generate the age key from the ssh host key
      # This generated age key was added to the list
      # of valid age keys in the bootstrap script
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    # Home-manager also needs access to the secrets. But it doesn't have permission
    # to read the ssh host key. So we have a seperate generated private age key per user.
    # We need to extract this private age key for the users from the secrets so home manager
    # can use it for decrypting.
    secrets = {
      "keys/age-key" = {
        owner = config.users.users.${config.hostSpec.username}.name;
        inherit (config.users.users.${config.hostSpec.username}) group;
        # We need to ensure the entire directory structure is that of the user...
        path = "${config.hostSpec.home}/.config/sops/age/keys.txt";
      };
    };
  };

  # The containing folders are created as root in the .config dir
  # so we need to change the perms
  system.activationScripts.sopsSetAgeKeyOwnership = let
    ageFolder = "${config.hostSpec.home}/.config/sops/age";
    user = config.users.users.${config.hostSpec.username}.name;
    group = config.users.users.${config.hostSpec.username}.group;
  in ''
    mkdir -p ${ageFolder} || true
    chown -R ${user}:${group} ${config.hostSpec.home}/.config
  '';
}
