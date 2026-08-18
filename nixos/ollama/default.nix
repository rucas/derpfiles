{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    loadModels = [
      "qwen2.5:7b"
      # Open WebUI's RAG embedding model — keeps SentenceTransformers out of
      # the web workers
      "nomic-embed-text"
    ];
    environmentVariables = {
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_NUM_PARALLEL = "2";
      GGML_VK_DISABLE_INTEGER_DOT_PRODUCT = "1";
    };
  };

  services.caddy.virtualHosts."ollama.rucaslab.com" = {
    extraConfig = ''
      reverse_proxy :11434
      encode zstd gzip
      tls {
        dns cloudflare {$CLOUDFLARE_API_TOKEN}
      }
      import access-log
    '';
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.intel-media-driver
      pkgs.intel-compute-runtime
      pkgs.vulkan-loader
    ];
  };
}
