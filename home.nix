{ config, pkgs, ... }:

{
  home.username = "nous";
  home.homeDirectory = "/home/nous";

  home.packages = [
    pkgs.nushell
    pkgs.htop
  ];

  home.file = {};

  home.sessionVariables = {
    EDITOR = "hx";
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
