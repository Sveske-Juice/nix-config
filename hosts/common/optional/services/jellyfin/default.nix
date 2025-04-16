{pkgs, ...}: let
  # configDir = "jellyfin"; # Relative from /etc/
  # configDirAbsolute = "/etc/${configDir}";
  group = "media";
in {
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  # AMD VA-API and VDPAU should work out of the box with mesa
  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = group;
    # configDir = configDirAbsolute;
  };

  # Configuration
  # We could declare settings declaratively like this, but i will just use the GUI
  # environment."${configDir}/system.xml".text = builtins.readFile ./system.xml;
  # environment."${configDir}/network.xml".text = builtins.readFile ./network.xml;

  users.users.jellyfin.extraGroups = ["video" "render"];
}
