{ lib, ... }:
{
  networking.networkmanager.enable = true;
  # Don't block boot waiting for the network. Nothing here mounts network
  # filesystems, so anything that needs the network at boot must retry itself.
  systemd.targets.network-online.wantedBy = lib.mkForce [ ]; # Normally ["multi-user.target"]
  systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ]; # Normally ["network-online.target"]

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    settings.publish = {
      disable-publishing = false;
      disable-user-service-publishing = false;
      publish-addresses = true;
      publish-domain = true;
      publish-hinfo = true;
      publish-workstation = true;
    };
  };
}
