{ ... }:

{
  # Discover audio over mDNS. Runs in the daemon context and auto-loads a pulse
  # tunnel (sink + source).
  services.pipewire.extraConfig.pipewire."99-zeroconf" = {
    "context.modules" = [
      {
        name = "libpipewire-module-zeroconf-discover";
        args = {
          # Retry in the background so audio resumes when niver comes back
          # online, without blocking eulfe's audio stack.
          "reconnect.interval.ms" = 15000;
        };
      }
    ];
  };

  # Make audio play out through remote by default. The tunnel presents itself as
  # a virtual network sink (PipeWire marks tunnel nodes with node.network =
  # "true"). WirePlumber selects the default audio sink by the `priority.session`
  # property, so raising it for the tunnel sink routes playback to niver.
  # WirePlumber only considers SINK streams for the default audio sink, so
  # eulfe's mic (the tunnel source) stays on its local input.
  services.pipewire.wireplumber.extraConfig."99-forward-to-niver" = {
    "stream.rules" = [
      {
        matches = [
          { node.network = "true"; }
        ];
        actions = {
          "update-props" = {
            "priority.session" = 99999;
          };
        };
      }
    ];
  };
}
