{
  description = "Basic system config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = github:nix-community/NUR;
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    disko,
    nixos-hardware,
    home-manager,
    nur,
    ...
  }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    # firefox-addons = import firefox-addons {
    #   inherit system;
    # };
    # addons = pkgs.nur.repos.rycee.firefox-addons;
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      eulfe = lib.nixosSystem {
        inherit system;
        modules = [
          nur.modules.nixos.default
          ./hosts/eulfe/configuration.nix
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nous = import ./hosts/eulfe/home.nix;
              extraSpecialArgs = { username = "nous"; nixosVersion = "24.11"; };
            };
          }
        ];
      };
      lucal = lib.nixosSystem {
        inherit system;
        modules = [
          nur.modules.nixos.default
          ./hosts/lucal/configuration.nix
          ./system/hidpi.nix
          disko.nixosModules.disko
          nixos-hardware.nixosModules.dell-xps-13-9350
          nixos-hardware.nixosModules.common-hidpi
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nous = import ./hosts/lucal/home.nix;
              extraSpecialArgs = { username = "nous"; nixosVersion = "24.11"; };
            };
          }
        ];
      };
    };
  };
}
