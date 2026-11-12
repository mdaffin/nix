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

  # Autologin starts the compositor as soon as greetd is up, which was before
  # amdgpu had loaded; load it in stage 1 so the display exists by then.
  hardware.amdgpu.initrd.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "nous";
  };

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
