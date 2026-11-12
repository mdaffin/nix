{ inputs, lib, ... }:
{
  imports = [ inputs.nixos-hardware.nixosModules.common-hidpi ];

  services.libinput.touchpad = {
    tapping = false;
    disableWhileTyping = true;
    naturalScrolling = true;
    clickMethod = "clickfinger";
    accelProfile = "flat";
    accelSpeed = "1";
  };

  # Laptop joins untrusted networks: resolve .local names but don't announce
  # hostname/hardware info.
  services.avahi.settings.publish.disable-publishing = lib.mkForce true;
}
