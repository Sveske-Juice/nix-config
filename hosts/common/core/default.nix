{lib, ...}: {
  imports = [
    ../../../modules/common

    ./tmux.nix
    ./sops.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnfree = true;

  security.sudo.extraConfig = ''
    Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
    Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
    Defaults timestamp_timeout=120 # only ask for password every 2h
  '';
}
