{ pkgs, ... }:
{
  programs = {
    bat.enable = true;
    fd.enable = true;
    fzf = {
      enable = true;
      # Workaround: the Home Manager nushell integration also sources fzf's
      # completion.nu, which uses the deprecated positional `spans` completer
      # input and prints a nu::shell::deprecated warning on nushell 0.116+.
      # Only the key bindings are sourced manually in the nushell config below.
      # Remove this and the manual source once fzf's completion.nu is fixed.
      enableNushellIntegration = false;
    };
    jq.enable = true;
    ripgrep.enable = true;

    nushell = {
      enable = true;
      loadSessionVariables = true;
      extraConfig = ''
        use std/dirs shells-aliases *
        $env.config = {
          show_banner: false
        }

        # Workaround for the fzf nushell integration being disabled above, this
        # keeps Ctrl+R/Ctrl+T/Alt+C. It must come after `$env.config` is set
        # or the keybindings it adds would be overwritten.
        source ${pkgs.fzf}/share/fzf/key-bindings.nu
      '';
    };

    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    starship = {
      enable = true;
      enableNushellIntegration = true;

      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];
}
