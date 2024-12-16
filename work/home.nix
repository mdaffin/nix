{ config, ... }:
{
  home = {
    homeDirectory = "/Users/" + config.home.username;
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  programs.nushell = {
    enable = true;
  };
}
