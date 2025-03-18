{
  description = "Configuration for NAS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};

    # Create a nixos configuration for specified host
    mkHost = host: {
      ${host} = lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/nixos/${host}];
      };
    };

    # Invoke mkHost foreach host config in passed hosts param
    # foldl for left folding which combines all the hosts into 1 attribute-set
    mkHostConfigs = hosts: lib.foldl (a: b: a // b) {} (lib.map (host: mkHost host) hosts);

    readHosts = folder: lib.attrNames (builtins.readDir ./hosts/${folder});
  in {
    formatter.${system} = pkgs.alejandra;

    nixosConfigurations = mkHostConfigs (readHosts "nixos");
    # let
    # in {
    #   lateralus = nixpkgs.lib.nixosSystem {
    #     specialArgs = {inherit inputs;};
    #     modules = [
    #       inputs.disko.nixosModules.default
    #       inputs.home-manager.nixosModules.default
    #       inputs.stylix.nixosModules.stylix
    #
    #       ./hosts/lateralus
    #       ./hosts/common/optional/vm-hardware-configuration.nix
    #     ];
    #   };
    #   waltherbox = nixpkgs.lib.nixosSystem {
    #     specialArgs = {inherit inputs;};
    #     modules = [
    #       inputs.disko.nixosModules.default
    #       inputs.home-manager.nixosModules.default
    #
    #       ./hosts/waltherbox
    #
    #       (import ./hosts/common/optional/zfsraid-disko.nix {
    #         pkgs = pkgs;
    #         swap-size = "16G";
    #         root-disk = "/dev/nvme0n1";
    #         raid-disks = [
    #           "sda"
    #           "sdb"
    #           "sdc"
    #         ];
    #       })
    #     ];
    #   };
    #   waltherbox-vm = nixpkgs.lib.nixosSystem {
    #     specialArgs = {inherit inputs;};
    #     modules = [
    #       inputs.disko.nixosModules.default
    #       inputs.home-manager.nixosModules.default
    #
    #       ./hosts/waltherbox
    #       ./hosts/common/optional/vm-hardware-configuration.nix
    #
    #       (import ./hosts/common/optional/zfsraid-disko.nix {
    #         pkgs = pkgs;
    #         swap-size = -1; # no swap in vm
    #         root-disk = "/dev/vda";
    #         raid-disks = [
    #           "vdb"
    #           "vdc"
    #           "vdd"
    #         ];
    #       })
    #     ];
    #   };
    # };
  };
}
