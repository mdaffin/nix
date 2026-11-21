{ pkgs, inputs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    host = "127.0.0.1";
    port = 11434;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "30m";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_CONTEXT_LENGTH = "64000";
    };
  };
}
