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
    };

    outputs = {
        self,
        nixpkgs,
        ...
    } @ inputs: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system;};
    in {
        formatter.${system} = pkgs.alejandra;

        nixosConfigurations = let
            modules = [
                inputs.disko.nixosModules.default
                inputs.home-manager.nixosModules.default
            ];
        in {
            server-vm = nixpkgs.lib.nixosSystem {
                specialArgs = { inherit inputs; };
                modules = [
                    (import ./disko.nix {
                        lib = pkgs.lib;
                        swap-size = -1; # no swap in vm
                        root-disk = "/dev/vda";
                        raid-disks = [
                            "vdb"
                            "vdc"
                            "vdd"
                        ];
                    })

                    ./vm-hardware-configuration.nix
                    ./configuration.nix
                ] ++ modules;
            };

            server = nixpkgs.lib.nixosSystem {
                specialArgs = {inherit inputs;};
                modules =
                  [
                    (import ./disko.nix {
                      lib = pkgs.lib;
                      swap-size = "128G";
                      root-disk = "/dev/nvme0n1";
                      raid-disks = [
                        "sda"
                        "sdb"
                        "sdc"
                        "sdd"
                      ];
                    })

                    # ./modules/networking-metal.nix
                    ./hardware-configuration.nix
                    ./configuration.nix
                  ]
                  ++ modules;
              };
        };
    };
}
