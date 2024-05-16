{ config, pkgs, unstable, username, nixosVersion, ... }:

{
  imports = [
    ../../user/home.nix
    ../../user/hidpi.nix
  ];
}
