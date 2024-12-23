{ username, ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
