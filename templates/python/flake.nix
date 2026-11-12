{
  description = "python development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      forEachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            venvDir = ".venv";
            packages = [
              pkgs.python3
              pkgs.python3Packages.pip
              pkgs.python3Packages.venvShellHook
            ];
          };
        }
      );
    };
}
