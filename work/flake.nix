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
        inherit inputs;

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };

    in
    {
      darwinConfigurations.work = darwin.lib.darwinSystem {
        inherit system;
        inherit specialArgs;

        modules = [
          ./core.nix
          ./legacy.nix
          # ./homebrew.nix
          ./system.nix

          home-manager.darwinModules.home-manager
          (
           { config, ... }:
           {
             home-manager = {
               useGlobalPkgs = true;
               useUserPackages = true;
               extraSpecialArgs = specialArgs;

               users.${username} = {
                 imports = [ ./home.nix ];
                 home.username = username;
               };
             };

              users.users.${username} = {
                home = "/Users/${username}";
              };

              # networking.hostName = hostname;
              # networking.computerName = config.networking.hostName;
           }
          )
        ];
      };
    };
}
