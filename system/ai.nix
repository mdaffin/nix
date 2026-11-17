{pkgs, inputs, ...}: {
  services.ollama = {
    enable = true;
    # From nixpkgs master: newer than the nixos-unstable branch.
    # RX 6800/XT/6900 XT.
    package =
      inputs.nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}
        .ollama-rocm;
    host = "127.0.0.1";
    port = 11434;
    environmentVariables = {
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_CONTEXT_LENGTH = "64000";
    };
  };
}
