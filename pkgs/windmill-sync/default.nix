{
  writeShellApplication,
  curl,
  jq,
  coreutils,
  ...
}:

writeShellApplication {
  name = "windmill-sync";

  runtimeInputs = [
    curl
    jq
    coreutils
  ];

  text = ''
    SCRIPTS_DIR="''${1:?Usage: windmill-sync <scripts-dir> <base-url> <token-file> [workspace]}"
    BASE_URL="''${2:?Missing base URL}"
    TOKEN_FILE="''${3:?Missing token file}"
    WORKSPACE="''${4:-admins}"

    TOKEN=$(cat "$TOKEN_FILE")

    api() {
      local method="$1" endpoint="$2"
      shift 2
      curl -sf -X "$method" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        "$BASE_URL/api/w/$WORKSPACE$endpoint" "$@"
    }

    # An optional `schedule` in meta.json ({cron, timezone, args}; cron has a
    # leading seconds field) becomes a schedule at the script's own path,
    # created or overwritten on every sync. A failure only warns, so one bad
    # schedule does not stop the remaining scripts from syncing.
    sync_schedule() {
      local meta="$1" path="$2" schedule
      schedule=$(jq -c '.schedule // empty' "$meta")
      [ -n "$schedule" ] || return 0

      local action body
      if [ "$(api GET "/schedules/exists/$path" || echo false)" = "true" ]; then
        action="update/$path"
        body=$(jq -n --argjson s "$schedule" \
          '{schedule: $s.cron, timezone: $s.timezone, args: ($s.args // {})}')
      else
        action="create"
        body=$(jq -n --argjson s "$schedule" --arg path "$path" \
          '{path: $path, script_path: $path, is_flow: false, enabled: true,
            schedule: $s.cron, timezone: $s.timezone, args: ($s.args // {})}')
      fi

      if api POST "/schedules/$action" -d "$body" > /dev/null; then
        echo "SCHEDULE OK: $path"
      else
        echo "WARN: schedule $action failed: $path"
      fi
    }

    for dir in "$SCRIPTS_DIR"/*/; do
      [ -d "$dir" ] || continue

      meta="$dir/meta.json"
      [ -f "$meta" ] || { echo "WARN: no meta.json in $dir"; continue; }

      path=$(jq -r '.path' "$meta")
      lang=$(jq -r '.language' "$meta")
      summary=$(jq -r '.summary // ""' "$meta")
      description=$(jq -r '.description // ""' "$meta")
      code_file="$dir/$(jq -r '.code_file' "$meta")"

      [ -f "$code_file" ] || { echo "WARN: code file missing: $code_file"; continue; }

      content=$(cat "$code_file")

      existing=$(api GET "/scripts/get/p/$path" 2>/dev/null || true)
      if [ -n "$existing" ]; then
        existing_hash=$(echo "$existing" | jq -r '.hash')
        existing_content=$(echo "$existing" | jq -r '.content')
        if [ "$existing_content" = "$content" ]; then
          echo "SKIP: $path (unchanged)"
          sync_schedule "$meta" "$path"
          continue
        fi
        echo "UPDATE: $path"
      else
        echo "CREATE: $path"
        existing_hash=""
      fi

      schema=$(jq -r '.schema // empty' "$meta")

      payload=$(jq -n \
        --arg path "$path" \
        --arg summary "$summary" \
        --arg description "$description" \
        --arg content "$content" \
        --arg language "$lang" \
        --arg parent_hash "$existing_hash" \
        --argjson schema "''${schema:-null}" \
        '{path: $path, summary: $summary, description: $description, content: $content, language: $language} + (if $parent_hash != "" then {parent_hash: $parent_hash} else {} end) + (if $schema != null then {schema: $schema} else {} end)')

      api POST "/scripts/create" -d "$payload" > /dev/null
      echo "OK: $path"
      sync_schedule "$meta" "$path"
    done
  '';
}
