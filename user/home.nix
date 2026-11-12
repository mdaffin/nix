{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./base.nix
    inputs.nix-index-database.homeModules.nix-index
    ./browser.nix
    ./cli-extras.nix
    ./editor.nix
    ./git.nix
    ./language-servers.nix
    ./shell.nix
  ];

  home = {
    preferXdgDirectories = true;
  };

  programs = {
    imv.enable = true;

    git = {
      settings.user.email = "github.palpable@so3.uk";
      settings.user.name = "nous";
      signing.format = null;
    };
  };

  services = {
    mpris-proxy.enable = true;
    # mpd.enable = true;
    playerctld.enable = true;
  };

  home.packages = with pkgs; [
    orca-slicer
    ente-desktop
    discord
    obsidian
    pavucontrol
    proton-vpn
    signal-desktop
    wl-clipboard
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

  xdg.autostart = {
    enable = true;
    readOnly = true;
    entries = [
      "${pkgs.steam}/share/applications/steam.desktop"
    ];
  };
}
