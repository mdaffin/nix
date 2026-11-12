{ pkgs, ... }:

{
  hardware.display = {
    edid.packages = [
      (pkgs.runCommand "edid-custom" { } ''
        mkdir -p $out/lib/firmware/edid
        base64 -d > "$out/lib/firmware/edid/XB270HU_4294967295.bin" <<'EOF'
        AP///////wAEcggE//////8XAQSlPCJ4Bu6Ro1RMmSYPUFQAAAABAQEBAQEBAQEBAQEBAQEBVl4A
        oKCgKVAwIDUAVlAhAAAaAAAA/wAjQVNNSGVLY0I4TERkAAAA/QAelh7SNgEKICAgICAgAAAA/ABY
        QjI3MEhVCiAgICAgAVACAwoBZUsEAAEBWocAoKCgO1AwIDUAVlAhAAAaWqAAoKCgRlAwIDUAVlAh
        AAAab8IAoKCgVVAwIDUAVlAhAAAadNIAFqCgCVAEEBEAVlAhAAAeHCUAoKCgEVAwIDUAVlAhAAAa
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAArw==
        EOF
      '')
    ];
    outputs."DP-1" = {
      mode = "e";
      edid = "XB270HU_4294967295.bin";
    };
  };
}
