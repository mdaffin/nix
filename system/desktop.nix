_: {
  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.pathsToLink = [ "/libexec" ];

  services = {
    logind.settings.Login.HandlePowerKey = "sleep";
    logind.settings.Login.HandlePowerKeyLongPress = "poweroff";
    udisks2.enable = true;
    desktopManager.cosmic.enable = true;
    displayManager = {
      cosmic-greeter.enable = true;
    };
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };
    printing.enable = true;
  };
}
