{
  description = "Flake for my NixOS configurations and programs";

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

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    inherit (inputs) nvf;
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};

    # Create a nixos configuration for specified host
    mkHost = host: {
      ${host} = lib.nixosSystem {
        specialArgs = {
          inherit self;
          inherit inputs;
        };
        modules = [./hosts/nixos/${host}];
      };
    };

    # Invoke mkHost foreach host config in passed hosts param
    # foldl for left folding which combines all the hosts into 1 attribute-set
    mkHostConfigs = hosts: lib.foldl (a: b: a // b) {} (lib.map (host: mkHost host) hosts);

    readHosts = folder: lib.attrNames (builtins.readDir ./hosts/${folder});
  in {
    formatter.${system} = pkgs.alejandra;


    # Custom packages
    packages.${system} = {
      "neovim" =
        (nvf.lib.neovimConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./modules/nvf
          ];
        })
        .neovim;
    };

    # Automatically generate nixos configurations foreach sub directory under ./hosts
    nixosConfigurations = mkHostConfigs (readHosts "nixos");
  };
}
