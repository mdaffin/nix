{ pkgs, ... }:
{
  programs = {
    helix = {
      enable = true;
      defaultEditor = true;
      # Needed by `editor.shell` below; the language servers are in
      # language-servers.nix.
      extraPackages = [ pkgs.nushell ];
      settings = {
        theme = "bogster";
        keys.normal."space" = {
          n = ":append-output pbpaste | str trim | str trim --char '#'";
        };
        editor = {
          auto-pairs = false;
          true-color = true;
          soft-wrap.enable = true;
          end-of-line-diagnostics = "hint";
          shell = [
            "nu"
            "-c"
          ];

          inline-diagnostics = {
            cursor-line = "warning";
          };

          indent-guides = {
            render = true;
            character = "│";
          };

          lsp = {
            display-signature-help-docs = true;
          };
        };
      };
    };
  };
}
