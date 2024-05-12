{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-configuration.nix
    ../../system/common.nix
  ];
}
