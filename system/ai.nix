{ pkgs, inputs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;

    # gfx1030 on the RX 6800; ROCm sometimes needs this to avoid CPU fallback.
    # Safe even if natively detected — add/adjust after checking service logs.
    rocmOverrideGfx = "10.3.0";

    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "6h";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_CONTEXT_LENGTH = "64000";
    };
  };
}
