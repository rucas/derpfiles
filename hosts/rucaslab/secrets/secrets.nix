let
  users = {
    personal-5c-nano = "age1yubikey1qw66f5dnzkjawww9rlhk9drce9v2awp7jaxk4uq6mq0lyevj0q67gu99z9j";
    github-actions = "age15rwtta9pketkwxj7gy5altkhlt8phr6w3p40ya4j6ysg9qgpr92smlkq2q";
  };
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVJRnte7uoSXii9cPSpsvLqSwyzFu0hu5Rn3Mfm7W5d root@rucaslab";
in
{
  "tailscale.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "cloudflare.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "cloudflare_dynamicdns.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "lutron.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "tailscale_golink.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "zigbee2mqtt.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "mosquitto.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "zwave_js_ui.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "nix.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "paperless-ngx.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "obsidian.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "lldap_key_seed.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "lldap_jwt_secret.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "lldap_ldap_user_pass.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "authelia_jwt_secret.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "authelia_storage_encryption_key.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "authelia_authentication_backend_ldap_password.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "authelia_session_secret.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
  "authelia_notifier_smtp_password.age".publicKeys = [
    users.personal-5c-nano
    users.github-actions
    system
  ];
}
