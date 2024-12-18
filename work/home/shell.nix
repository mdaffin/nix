{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell.program = "nu";
      font.normal.family = "JetbrainsMono Nerd Font";
      hints.enabled = [{
          action = "Copy";
          post_processing = true;
          regex = "STAR-[0-9]+";
      }];
    };
  };

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
    };
  };

  programs.ripgrep.enable = true;
  programs.bottom.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.jq.enable = true;

  home.packages = with pkgs; [
    sd
    yq
  ];
}
