{ ... }: {
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.rucaslab.com";
      upstream-base-url = "https://ntfy.sh";
      listen-http = ":1234";
      behind-proxy = true;
    };
  };
}
