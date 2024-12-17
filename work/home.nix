{ config, ... }:
{
  home = {
    homeDirectory = "/Users/" + config.home.username;
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  programs.nushell = {
    enable = true;
    extraConfig = ''
      $env.config = {
        show_banner: false
      }
      use ~/.local/wt
      use std/dirs shells-aliases *
    '';

    extraEnv = ''
      $env.EDITOR = 'hx'
    '';
  };
}
