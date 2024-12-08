{ config, pkgs, unstable, username, nixosVersion, ... }:

{
  imports = [
    ./i3.nix
    ./firefox.nix
  ];

  home = {
    username = username;
    homeDirectory = "/home/" + username;
    # preferXdgDirectories = true; # enable on 24.05
    sessionPath = [
      "$HOME/.local/bin"
    ];
    stateVersion = nixosVersion;
  };

  programs = {
    home-manager.enable = true;
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

    fzf = {
      enable = true;
    };

    git = {
      enable = true;
      userEmail = "github.reformat799@passmail.net";
      userName = "nous";
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
    playerctld.enable = true;
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    htop
    xsel
    obsidian
    pavucontrol
    discord
    vesktop
    nemo
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
}
