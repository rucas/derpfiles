# Windmill passes the schema's arguments positionally, in meta.json order.
# DOOR_CODE_SYNC (nixos/windmill/default.nix) already carries the secret file
# paths and the state file, so no secret ever passes through job arguments.
lldap_url="$1"
lldap_user="$2"
group="$3"
ha_url="$4"
lcm_entry="$5"
dry_run="$6"

flags=()
if [ "$dry_run" = "true" ]; then
  flags+=(--dry-run)
fi

"$DOOR_CODE_SYNC" \
  --lldap-url "$lldap_url" \
  --lldap-user "$lldap_user" \
  --group "$group" \
  --ha-url "$ha_url" \
  --lcm-entry "$lcm_entry" \
  "${flags[@]}"
