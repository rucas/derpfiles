#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

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

cp package-lock.json "$OLDPWD/package-lock.json"
echo "Updated package-lock.json"

cd "$OLDPWD"
echo "Fetching source hash..."
hash=$(nix-prefetch-url --type sha256 "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz" 2>/dev/null)
sri_hash=$(nix hash to-sri --type sha256 "$hash")

echo "Updating default.nix..."
sed -i.bak "s/version = \".*\";/version = \"$version\";/" default.nix
sed -i.bak "s|hash = \"sha256-.*\";|hash = \"$sri_hash\";|" default.nix
rm -f default.nix.bak

echo "Done! Updated to version $version"
echo "Note: You may need to update npmDepsHash if dependencies changed."
echo "Build the package and Nix will show the correct hash if needed."
