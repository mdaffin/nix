{
  description = "Basic system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # nixpkgs tracks nixos-unstable, so use the matching home-manager branch
      # (master). A release branch would need to be bumped together with nixpkgs.
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      disko,
      home-manager,
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      mkNixos =
        {
          hostname,
          modules ? [ ],
          system ? "x86_64-linux",
          user ? "nous",
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            {
              nixpkgs.hostPlatform = system;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./user/home.nix;
                extraSpecialArgs = {
                  inherit inputs;
                  username = user;
                };
              };
            }
          ]
          ++ modules;
        };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
      forAllSystems = f: forEachSystem (system: f nixpkgs.legacyPackages.${system});

      rustShell =
        system:
        import ./shells/rust.nix (
          import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          }
        );
    in
    {
      lib = { inherit forEachSystem rustShell; };

      # Home-manager modules for other flakes to import. `base` needs a
      # `username` specialArg from the consumer.
      homeModules = {
        base = {
          imports = [
            ./user/base.nix
            inputs.nix-index-database.homeModules.nix-index
          ];
        };
        cli-extras = ./user/cli-extras.nix;
        editor = ./user/editor.nix;
        git = ./user/git.nix;
        language-servers = ./user/language-servers.nix;
        shell = ./user/shell.nix;
      };

      nixosModules.nix-settings = ./system/nix.nix;
      darwinModules.nix-settings = ./system/nix.nix;

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.deadnix
            pkgs.nixfmt-tree
            pkgs.statix
          ];
        };
        go = import ./shells/go.nix pkgs;
        kube = import ./shells/kube.nix pkgs;
        python = import ./shells/python.nix pkgs;
        rust = rustShell pkgs.stdenv.hostPlatform.system { };
      });

      templates = {
        go = {
          path = ./templates/go;
          description = "Go development environment";
        };
        kube = {
          path = ./templates/kube;
          description = "Kubernetes development environment";
        };
        python = {
          path = ./templates/python;
          description = "Python development environment";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust development environment";
        };
      };

      checks = forAllSystems (pkgs: {
        formatting = pkgs.runCommand "check-formatting" { nativeBuildInputs = [ pkgs.nixfmt ]; } ''
          cd ${./.}
          find . -name '*.nix' -print0 \
            | xargs -0 nixfmt --check
          touch $out
        '';
        statix = pkgs.runCommand "check-statix" { nativeBuildInputs = [ pkgs.statix ]; } ''
          cd ${./.}
          statix check .
          touch $out
        '';
      });

      nixosConfigurations = {
        iso = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/iso/configuration.nix ];
        };
        niver = mkNixos { hostname = "niver"; };
        eulfe = mkNixos { hostname = "eulfe"; };
        lucal = mkNixos { hostname = "lucal"; };
      };
    };
}
