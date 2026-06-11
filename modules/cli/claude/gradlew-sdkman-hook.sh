#!/usr/bin/env bash
# PreToolUse hook: transparently bootstraps the SDKMAN environment for Gradle/
# Kotlin commands so `./gradlew ...` works without a hand-typed env prefix.
#
# Reads the Bash tool input on stdin. When the command invokes gradle/sdk/kotlinc
# (and is not already bootstrapped), it rewrites the command to source SDKMAN and
# select the toolchain from the nearest .sdkmanrc, then returns it via updatedInput
# with permissionDecision "defer" so the cc-safety-net hook still governs allow/deny.

set -euo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
[ -n "$cmd" ] || exit 0

# Idempotent: skip if already bootstrapped.
case "$cmd" in
*SDKMAN_DIR* | *sdkman-init*) exit 0 ;;
esac

# Only act on gradle/sdk/kotlin invocations.
if ! printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])(\./gradlew|gradlew|gradle|sdk|kotlinc)([[:space:];&|]|$)'; then
  exit 0
fi

sdkman_dir=/opt/homebrew/opt/sdkman-cli/libexec
[ -f "$sdkman_dir/bin/sdkman-init.sh" ] || exit 0

# Resolve toolchain from the nearest .sdkmanrc (walk up from cwd).
uses=""
dir=$PWD
while [ "$dir" != "/" ]; do
  if [ -f "$dir/.sdkmanrc" ]; then
    while IFS='=' read -r key val; do
      key=$(printf '%s' "$key" | tr -d '[:space:]')
      val=$(printf '%s' "$val" | tr -d '[:space:]')
      case "$key" in
      '' | '#'* | sdkman_auto_env) continue ;;
      esac
      [ -n "$val" ] && uses="$uses && sdk use $key $val >/dev/null 2>&1"
    done <"$dir/.sdkmanrc"
    break
  fi
  dir=$(dirname "$dir")
done
[ -n "$uses" ] || uses=" && sdk use kotlin 2.2.0 >/dev/null 2>&1"

prefix="export SDKMAN_DISABLE_COMPLETION=true && export SDKMAN_DIR=$sdkman_dir && source \"\$SDKMAN_DIR/bin/sdkman-init.sh\" >/dev/null 2>&1$uses && "

jq -n --arg cmd "$prefix$cmd" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "defer",
    updatedInput: { command: $cmd }
  }
}'
