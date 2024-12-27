{ ... }: {
  services.changedetection-io = {
    enable = true;
    behindProxy = true;
    baseURL = "https://changedetection.rucaslab.com";
  };
}
