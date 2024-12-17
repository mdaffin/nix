{ ... }:
{
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
          /nix/var/nix/profiles/default/bin,
          /Users/michael.daffin/.starling/bin,
          /Users/michael.daffin/.starling/opt/bin,
      ])
    '';
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    enableNushellIntegration = true;
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;

    settings = {
      # character = {
      #   success_symbol = "[›](bold green)";
      #   error_symbol = "[›](bold red)";
      # };
      # aws = {
      #   symbol = "🅰 ";
      # };
      # gcloud = {
      #   # do not show the account/project's info
      #   # to avoid the leak of sensitive information when sharing the terminal
      #   format = "on [$symbol$active(\($region\))]($style) ";
      #   symbol = "🅶 ️";
      # };
    };
  };
}
