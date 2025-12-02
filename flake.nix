{
  description = "Flake for my NixOS configurations and programs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:Sveske-Juice/nixpkgs/update-syncthing";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    declarative-jellyfin = {
      # url = "git+https://git.spoodythe.one/spoody/declarative-jellyfin.git?rev=cf31b92927a530d0842e7451e9bb51f9e76f238d";
      url = "git+https://git.spoodythe.one/spoody/declarative-jellyfin.git";
      # url = "git+https://git.spoodythe.one/spoody/declarative-jellyfin.git?ref=fix-root";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minimal-tmux = {
      url = "github:niksingh710/minimal-tmux-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tmux-sessionx = {
      url = "github:omerxx/tmux-sessionx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (inputs) nvf;

      # Create a nixos configuration for specified host
      mkHost = host: {
        ${host} = lib.nixosSystem {
          specialArgs = {
            inherit self;
            inherit inputs;
          };
          modules = [ ./hosts/nixos/${host} ];
        };
      };

      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      # Invoke mkHost foreach host config in passed hosts param
      # foldl for left folding which combines all the hosts into 1 attribute-set
      mkHostConfigs = hosts: lib.foldl (a: b: a // b) { } (lib.map (host: mkHost host) hosts);

      readHosts = folder: lib.attrNames (builtins.readDir ./hosts/${folder});
    in
    {
      # nix fmt
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # nix flake check
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      # Custom packages
      packages."x86_64-linux" = {
        "neovim" =
          (nvf.lib.neovimConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [ ./modules/nvf ];
          }).neovim;
      };

      # Automatically generate nixos configurations foreach sub directory under ./hosts
      nixosConfigurations = mkHostConfigs (readHosts "nixos");
    };
}
