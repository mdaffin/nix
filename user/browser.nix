{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
  desktopFile = "zen-beta.desktop";
  mimeTypes = [
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/x-extension-xht"
    "application/x-extension-xhtml"
    "application/xhtml+xml"
    "text/html"
    "x-scheme-handler/chrome"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ];
  zenForAll = lib.genAttrs mimeTypes (_: desktopFile);
in
{
  home.packages = [ zen ];
  xdg.autostart.enable = true;
  xdg.autostart.entries = [
    "${zen}/share/applications/zen-beta.desktop"
  ];
  xdg.mimeApps = {
    enable = true;
    defaultApplications = zenForAll;
    associations.added = zenForAll;
  };
}
