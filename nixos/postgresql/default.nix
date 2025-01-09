{ ... }: {
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "authelia-rucaslab" "hass" "lldap" ];
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
