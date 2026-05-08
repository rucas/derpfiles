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
    done
  '';
}
