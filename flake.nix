{
  description = "Basic system config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
  };
  outputs = { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        workshop = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./configuration.nix ];
        };
      };
    };
}
