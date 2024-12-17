{
  description = "A simple darwin flake using Aux and home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ darwin, home-manager, nixpkgs, ... }:
    let
      system = "aarch64-darwin";

      username = "michael.daffin";
      hostname = "POyxSJFtfKVY6WA==";

      specialArgs = {
        inherit inputs username hostname;

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
      darwinConfigurations.work = darwin.lib.darwinSystem {
        inherit system;
        inherit specialArgs;

        modules = [
          ./core.nix
          ./system.nix

          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${username} = import ./home;
            };
          }
        ];
      };
    };
}
