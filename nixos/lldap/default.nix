{ config, ... }: {
  services.lldap = {
    enable = true;
    settings = {
      ldap_base_dn = "dc=rucaslab,dc=com";
      ldap_user_email = "admin@rucaslab.com";
      database_url = "postgresql://lldap@localhost/lldap?host=/run/postgresql";
    };
    environment = {
      LLDAP_JWT_SECRET_FILE = config.age.secrets.lldap_jwt_secret.path;
      LLDAP_KEY_SEED_FILE = config.age.secrets.lldap_key_seed.path;
      LLDAP_LDAP_USER_PASS_FILE = config.age.secrets.lldap_ldap_user_pass.path;
    };
  };

  users = {
    users.lldap = {
      group = "lldap";
      isSystemUser = true;
    };
    groups.lldap = { };
  };

  systemd.services.lldap = let dependencies = [ "postgresql.service" ];
  in {
    # LLDAP requires PostgreSQL to be running
    after = dependencies;
    requires = dependencies;
  };
}
