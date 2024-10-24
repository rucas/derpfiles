let
  users = {
    personal-5c-nano =
      "age1yubikey1qw66f5dnzkjawww9rlhk9drce9v2awp7jaxk4uq6mq0lyevj0q67gu99z9j";
  };
  system =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVJRnte7uoSXii9cPSpsvLqSwyzFu0hu5Rn3Mfm7W5d root@rucaslab";
in {
  "tailscale.age".publicKeys = [ users.personal-5c-nano system ];
  "cloudflare.age".publicKeys = [ users.personal-5c-nano system ];
  "cloudflare_dynamicdns.age".publicKeys = [ users.personal-5c-nano system ];
  "lutron.age".publicKeys = [ users.personal-5c-nano system ];
  "tailscale_golink.age".publicKeys = [ users.personal-5c-nano system ];
  "zigbee2mqtt.age".publicKeys = [ users.personal-5c-nano system ];
  "mosquitto.age".publicKeys = [ users.personal-5c-nano system ];
  "zwave_js_ui.age".publicKeys = [ users.personal-5c-nano system ];
  "nix.age".publicKeys = [ users.personal-5c-nano system ];
  "paperless-ngx.age".publicKeys = [ users.personal-5c-nano system ];
  "obsidian.age".publicKeys = [ users.personal-5c-nano system ];
}
