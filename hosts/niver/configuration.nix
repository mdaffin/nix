{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-configuration.nix
    ./XB270HU.nix
    ../../system/audio.nix
    ../../system/bluetooth.nix
    ../../system/common.nix
    ../../system/containers.nix
    ../../system/desktop.nix
    ../../system/steam.nix
  ];
  # Release the default state settings come from, not the release being run.
  # Only change after reading the release notes, never in a routine update.
  system.stateVersion = "24.05";
  home-manager.users.nous.home.stateVersion = "24.11";

  networking = {
    hostName = "niver";
  };

  # The service runs the keybase daemon the GUI talks to.
  services.keybase.enable = true;
  environment.systemPackages = [ pkgs.keybase-gui ];

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    # network-online is not waited for at boot (see system/common.nix), so
    # retry until the network is up rather than ordering after it.
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 30;
    };
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
