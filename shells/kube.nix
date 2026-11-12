pkgs:
pkgs.mkShell {
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
}
