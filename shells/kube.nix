pkgs:
pkgs.mkShell {
  packages = with pkgs; [
    dive
    k3d
    kind
    kubectl
  ];
  shellHook = ''
    export KIND_CLUSTER_NAME="kind"
  '';
}
