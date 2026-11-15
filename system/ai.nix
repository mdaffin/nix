{pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm; # RX 6800/XT/6900 XT
    host = "127.0.0.1";
    port = 11434;
    environmentVariables = {
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_CONTEXT_LENGTH = "64000";
    };
  };
}
