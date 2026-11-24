{ lib, ... }:
{
  # NOTE on network audio (see system/audio.nix): eulfe tunnels its audio to
  # niver over the LAN. niver's PipeWire-Pulse server listens on tcp:4713 and
  # accepts any LAN peer (there is no fixed eulfe IP to restrict to). Nothing
  # here blocks that: networking.firewall is disabled (see below) and this
  # block only opens the avahi/mDNS UDP 5353 ports eulfe needs to discover
  # niver. If you ever enable the firewall on niver, you will need to allow
  # TCP 4713 to reach it.
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
