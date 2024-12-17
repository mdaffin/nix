{ username, ... }:
{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  programs.nushell = {
    enable = true;
    extraConfig = ''
      use std/dirs shells-aliases *
      $env.config = {
        show_banner: false
      }
    '';
    extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep) | prepend [
          /Users/michael.daffin/.local/bin,
          /Users/michael.daffin/.cargo/bin,
          # /run/current-system/sw/bin,
          # /nix/var/nix/profiles/default/bin,
          /Users/michael.daffin/.starling/bin,
          /Users/michael.daffin/.starling/opt/bin,
      ])
    '';
  };
}
