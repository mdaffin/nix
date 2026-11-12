{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../system/audio.nix
    ../../system/bluetooth.nix
    ../../system/common.nix
    (import ../../system/disko-single-disk.nix { device = "/dev/nvme0n1"; })
    ../../system/containers.nix
    ../../system/desktop.nix
    ../../system/laptop.nix
    inputs.nixos-hardware.nixosModules.dell-xps-13-9360
  ];
  # Release the default state settings come from, not the release being run.
  # Only change after reading the release notes, never in a routine update.
  system.stateVersion = "24.05";
  home-manager.users.nous.home.stateVersion = "24.11";

  networking = {
    hostName = "lucal";
  };
}
