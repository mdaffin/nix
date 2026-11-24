{ ... }:

{
  # WireWire-Pulse server socket. `unix:native` keeps the local session bus
  # working; `tcp:4713` is how client reach it over the LAN. The key matches
  # the daemon's own config and is merged by append.
  services.pipewire.extraConfig.pipewire-pulse."99-network" = {
    "pulse.properties.server.address" = [
      "unix:native"
      "tcp:4713"
    ];
  };

  # Advertise sink + source over mDNS so eulfe can discover it. This
  # runs in the protocol-pulse context.
  services.pipewire.extraConfig.pipewire-pulse."98-zeroconf" = {
    "pulse.cmd" = [
      {
        cmd = "load-module";
        args = "module-zeroconf-publish";
        flags = [ "nofail" ];
      }
    ];
  };
}
