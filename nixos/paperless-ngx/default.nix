{ config, ... }: {
  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless-ngx.path;
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [ ".DS_STORE/*" "desktop.ini" ];
      PAPERLESS_OCR_LANGUAGE = "eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
    };
  };
}
