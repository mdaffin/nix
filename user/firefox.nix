{ config, lib, pkgs, ... }:

{
  programs = {
    firefox = {
      enable = true;
      # profiles.default = {
      #   bookmarks = {};
      #   # extensions = with addons; [
      #   #   ublock-origin
      #   #   proton-pass
      #   # ];
      #   settings = {
      #     "browser.disableResetPrompt" = true;
      #     "browser.download.panel.shown" = true;
      #     "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      #     "browser.shell.checkDefaultBrowser" = false;
      #     "browser.shell.defaultBrowserCheckCount" = 1;
      #     "browser.startup.homepage" = "https://start.duckduckgo.com";
      #     "dom.security.https_only_mode" = true;
      #     "identity.fxaccounts.enabled" = false;
      #     "privacy.trackingprotection.enabled" = true;
      #     "signon.rememberSignons" = false;
      #   };
      # };
    };
  };
}

