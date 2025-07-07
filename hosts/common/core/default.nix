{ lib, pkgs, ... }:
{
  imports = [
    ./en_dk.nix
    ./host-spec.nix
    ./tmux.nix
    ./sops.nix
  ];

  # Automatic GC
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  environment.systemPackages = [
    pkgs.dotnetCorePackages.dotnet_8.sdk # required for omnisharp
  ];

  # https://nixos.wiki/wiki/DotNET
  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnetCorePackages.dotnet_8.sdk}/share/dotnet";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnfree = true;

  security.sudo.extraConfig = ''
    Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
    Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
    Defaults timestamp_timeout=120 # only ask for password every 2h
  '';

  # Takes forever on rebuild, don't need it
  documentation.man.generateCaches = false;
}
