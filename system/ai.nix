{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm; # RX 6800/XT/6900 XT = gfx1030, officially supported
      host = "127.0.0.1";
      port = 11434;
      environmentVariables = {
        OLLAMA_KV_CACHE_TYPE = "q8_0";
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KEEP_ALIVE = "5m";
        OLLAMA_CONTEXT_LENGTH = "64000";
      };
    };

    environment.systemPackages = [
      pkgs.bubblewrap
    ];
  };
}
