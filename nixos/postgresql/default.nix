{ ... }: {
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" "lldap" ];
    ensureUsers = [
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
