pkgs:
pkgs.mkShell {
  venvDir = ".venv";
  packages = [
    pkgs.python3
    pkgs.python3Packages.pip
    pkgs.python3Packages.venvShellHook
  ];
}
