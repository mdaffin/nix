{ config, pkgs, unstable, ... }:

{
  home.username = "nous";
  home.homeDirectory = "/home/nous";

  home.packages = with pkgs; [
    ripgrep
    helix
    htop
    wofi
    xsel
    firefox
    alacritty
    obsidian
    dunst
  ];

  home.file = {};

  programs = {
    nushell.enable = true;

    carapace = {
      enable = true;
      package = unstable.carapace;
      enableNushellIntegration = true;
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };

  home.sessionVariables = {
    EDITOR = "hx";
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
