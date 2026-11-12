{
  description = "kube development environment";

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
            packages = with pkgs; [
              dive
              k3d
              kind
              go
              ko
              kubectl
              tektoncd-cli
            ];
            shellHook = ''
              export KO_DOCKER_REPO="kind.local"
              export KIND_CLUSTER_NAME="kind"
            '';
          };
        }
      );
    };
}
