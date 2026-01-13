#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

version=${1:-$(npm view @anthropic-ai/claude-code version)}
echo "Updating to version $version"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cd "$tmpdir"
echo "Downloading claude-code $version..."
curl -sL "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz" | tar -xzf -

cd package
echo "Generating package-lock.json..."
AUTHORIZED=1 npm install --package-lock-only --legacy-peer-deps

cp package-lock.json "$SCRIPT_DIR/package-lock.json"
echo "Updated package-lock.json"

cd "$SCRIPT_DIR"
echo "Fetching source hash..."
sri_hash=$(nix-prefetch-url --unpack --type sha256 "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz" 2>&1 | grep -v warning | tail -1 | xargs nix hash to-sri --type sha256)

echo "Updating default.nix..."
sed -i.bak "s/version = \".*\";/version = \"$version\";/" default.nix
sed -i.bak "s|hash = \"sha256-.*\";|hash = \"$sri_hash\";|" default.nix
rm -f default.nix.bak

echo "Calculating npmDepsHash..."
sed -i.bak "s|npmDepsHash = \"sha256-.*\";|npmDepsHash = \"\";|" default.nix
rm -f default.nix.bak

cd ../..
build_output=$(nix build .#claude-code --no-link 2>&1 || true)
npm_hash=$(echo "$build_output" | grep "got:" | awk '{print $2}')
cd "$SCRIPT_DIR"

if [ -n "$npm_hash" ]; then
  echo "Updating npmDepsHash..."
  sed -i.bak "s|npmDepsHash = \"\";|npmDepsHash = \"$npm_hash\";|" default.nix
  rm -f default.nix.bak
  echo "Done! Updated to version $version"
else
  echo "Warning: Could not automatically determine npmDepsHash"
  echo "You may need to build the package and update it manually"
fi
