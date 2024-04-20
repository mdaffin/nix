{ config, pkgs, unstable, ... }:

{
  imports = [
    ./i3.nix
    ./hyprland.nix
  ];

  home = {
    username = "nous";
    homeDirectory = "/home/nous";
    # preferXdgDirectories = true; # enable on 24.05
    sessionPath = [
      "$HOME/.local/bin"
    ];
    stateVersion = "23.11";
  };

  programs = {
    nushell.enable = true;

    carapace = {
      enable = true;
      package = unstable.carapace;
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

    waybar = {
      enable = true;
      systemd.enable = true;
    };

    wofi = {
      enable = true;
    };

    alacritty = {
      enable = true;
    };

    bat.enable = true;
    bottom.enable = true;
    eza = { 
     enable = true;
      # enableNushellIntegration = true;
    };

    firefox = {
      enable = true;
    };

    fzf = {
      enable = true;
    };

    git = {
      enable = true;
    };

    helix = {
      enable = true;
      package = unstable.helix;
      defaultEditor = true;
      settings = {
        theme = "bogster";
        editor = {
          auto-pairs = false;
        };
      };
    };

    imv.enable = true;
    jq.enable = true;
  };

  services = {
    mpris-proxy.enable = true;
    mako.enable = true;
    # mpd.enable = true;
    udiskie.enable = true;
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    htop
    xsel
    firefox
    obsidian
    pavucontrol
    discord
    vesktop
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

  xdg.mimeApps.enable = true;
  # xdg.portal.enable = true; # not yet supported, check again on 24.05

  programs.home-manager.enable = true;
}
