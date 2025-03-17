{
  lib,
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    syncthingtray
  ];

  services.syncthing = {
    enable = true;
    group = "users";
    user = "sveske";
    dataDir = "/home/sveske/Documents"; # Default folder for new synced folders
    configDir = "/home/sveske/.config/syncthing"; # Folder for Syncthing's settings and keys
  };
}
