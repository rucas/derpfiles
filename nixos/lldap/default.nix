{ pkgs, config, ... }:
let
  httpUrl = "http://localhost:${toString config.services.lldap.settings.http_port}";
in
{
  services = {
    lldap = {
      enable = true;
      settings = {
        ldap_base_dn = "dc=rucaslab,dc=com";
        ldap_user_email = "admin@rucaslab.com";
        force_ldap_user_pass_reset = "always";
        database_url = "postgresql://lldap@localhost/lldap?host=/run/postgresql";
      };
      environment = {
        LLDAP_JWT_SECRET_FILE = config.age.secrets.lldap_jwt_secret.path;
        LLDAP_KEY_SEED_FILE = config.age.secrets.lldap_key_seed.path;
        LLDAP_LDAP_USER_PASS_FILE = config.age.secrets.lldap_ldap_user_pass.path;
      };
    };

    caddy = {
      virtualHosts = {
        "lldap.rucaslab.com" = {
          extraConfig = ''
            import https-proxy :${toString config.services.lldap.settings.http_port}
          '';
        };
      };
    };
  };

  users = {
    users.lldap = {
      group = "lldap";
      isSystemUser = true;
    };
    groups.lldap = { };
  };

  systemd.services = {
    lldap =
      let
        dependencies = [ "postgresql.service" ];
      in
      {
        # LLDAP requires PostgreSQL to be running
        after = dependencies;
        requires = dependencies;
      };

    # lldap has no declarative schema, so add what the windmill door_code_sync
    # script reads: a `door-code` user attribute (names allow only
    # `[A-Za-z0-9-]`) that regular users can neither see nor edit (admins and
    # lldap_strict_readonly members still read it), and the `door_access`
    # group whose members get their code pushed to the lock and Alarmo.
    lldap-door-code-schema = {
      description = "Ensure lldap door code attribute and group";
      after = [ "lldap.service" ];
      requires = [ "lldap.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.curl
        pkgs.jq
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "lldap";
        Group = "lldap";
      };
      script = ''
        until curl -sf ${httpUrl}/health > /dev/null; do
          sleep 2
        done

        token=$(jq -n \
          --arg user ${config.services.lldap.settings.ldap_user_dn} \
          --rawfile pass "$LLDAP_LDAP_USER_PASS_FILE" \
          '{username: $user, password: ($pass | rtrimstr("\n"))}' \
          | curl -sf ${httpUrl}/auth/simple/login -H 'Content-Type: application/json' -d @- \
          | jq -er .token)

        # GraphQL reports failures in a 200 body, so fail on `errors` too.
        gql() {
          jq -n --arg q "$1" '{query: $q}' \
            | curl -sf ${httpUrl}/api/graphql \
                -H "Authorization: Bearer $token" \
                -H 'Content-Type: application/json' -d @- \
            | jq -e 'if .errors then error(.errors | tostring) else . end'
        }

        state=$(gql '{ schema { userSchema { attributes { name } } } groups { displayName } }')

        if ! jq -e '.data.schema.userSchema.attributes | any(.name == "door-code")' <<< "$state" > /dev/null; then
          gql 'mutation { addUserAttribute(name: "door-code", attributeType: STRING, isList: false, isVisible: false, isEditable: false) { ok } }'
          echo "created door-code attribute"
        fi

        if ! jq -e '.data.groups | any(.displayName == "door_access")' <<< "$state" > /dev/null; then
          gql 'mutation { createGroup(name: "door_access") { id } }'
          echo "created door_access group"
        fi
      '';
      environment.LLDAP_LDAP_USER_PASS_FILE = config.age.secrets.lldap_ldap_user_pass.path;
    };
  };
}
