{ lib }: {
  toToString = str: toString str;
  proxify = host: port: {
    caddy = {
      virtualHosts = {
        "${host}" = { extraConfig = "import https-proxy :${toString port}"; };
      };
    };
  };
}
