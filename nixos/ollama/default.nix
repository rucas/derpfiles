{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    loadModels = [ "qwen2.5:7b" ];
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
    '';
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vulkan-loader
    ];
  };
}
