_: {
  services.postgresql = {
    enable = true;
    dataDir = "/data/postgresql/14";
    ensureDatabases = [
      "authelia-rucaslab"
      "hass"
      "lldap"
    ];
    ensureUsers = [
      {
        name = "authelia-rucaslab";
        ensureDBOwnership = true;
      }
      {
        name = "hass";
        ensureDBOwnership = true;
      }
      {
        name = "lldap";
        ensureDBOwnership = true;
      }
    ];
  };
}
