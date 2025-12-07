{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    protontricks.enable = true;
    gamescopeSession = {
      enable = true;
      args = [ "--hdr-enabled" ];
    };
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  # Steam game traffic for Open NAT
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 27014;
      to = 27050;
    }
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 27014;
      to = 27050;
    }
  ];
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
}
