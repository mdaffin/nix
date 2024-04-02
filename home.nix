{ config, pkgs, unstable, ... }:

{
  home.username = "nous";
  home.homeDirectory = "/home/nous";

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

  home.packages = with pkgs; [
    ripgrep
    fd
    helix
    htop
    wofi
    xsel
    firefox
    alacritty
    obsidian
    dunst
  ];

  xdg.desktopEntries = {
    obsidian = {
      name = "Obsidian";
      comment = "Knowledge base";
      exec = "env LD_LIBRARY_PATH=${pkgs.libGL}/lib obsidian %u";
      icon = "obsidian";
      type = "Application";
      categories = [ "Office" ];
      mimeType = [ "x-scheme-handler/obsidian" ];
    };
  };

  home.file = {};

  home.sessionVariables = {
    EDITOR = "hx";
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
