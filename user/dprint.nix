{ pkgs, ... }:
{
  # dprint formatter, using the markdown plugin. Configured via the
  # home-manager `programs.dprint` module so dprint.json is written to
  # $XDG_CONFIG_HOME/dprint/dprint.json. The plugin path here matches the
  # plugin helix's markdown formatter (see editor.nix) resolves via the
  # dprint config, keeping both setups in sync.
  programs.dprint = {
    enable = true;
    settings = {
      markdown = { };
      plugins = [
        "${pkgs.dprint-plugins.dprint-plugin-markdown}/plugin.wasm"
      ];
    };
  };

  home.packages = [
    pkgs.dprint
  ];
}
