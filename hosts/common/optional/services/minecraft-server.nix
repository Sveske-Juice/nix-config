{inputs, pkgs, ...}: {
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.cvpl = {
      enable = true;
      package = pkgs.fabricServers.fabric-1_21_11;
    };
  };
}
