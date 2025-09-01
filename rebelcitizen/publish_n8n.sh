#!/usr/bin/env bash
set -euo pipefail

# ── sanity ─────────────────────────────────────────────────────────────
#test -n "${GH_NPM_TOKEN:-}" \
#  || { echo "❌  GH_NPM_TOKEN not set"; exit 1; }

# ── 1. build all workspaces we’re about to publish ─────────────────────
pnpm build

# ── 2. bump the version if you like (optional) ─────────────────────────
#pnpm version prerelease --preid "$(date +%Y%m%d%H%M)"

echo "Will start publishing packages"

# Sentinel file to know which tarballs are new
MARKER="$(mktemp)"
touch "$MARKER"


pnpm pack -r --filter "./packages/**"

# ── 3. publish every package that has "private": false ─────────────────
#     (--recursive = follow workspaces)
#pnpm publish -r --filter "./packages/**" --access=restricted  --no-git-checks --reporter default --dry-run --force

# ── 2. move all .tgz files created *after* the marker into ./Packs ────────────
OUT_DIR="./Packs"
rm -rf "$OUT_DIR" && mkdir -p "$OUT_DIR"

find . -type f -name '*.tgz' -newer "$MARKER" -print0 \
  | while IFS= read -r -d '' pkg ; do
        echo "→  $(basename "$pkg")"
        mv "$pkg" "$OUT_DIR"/
    done

rm "$MARKER"

OUT_DIR="$(pwd)/Packs"
REMOTE="d2ff2da2-c9fd-4d28-ab8e-ce4c3836561d@d2ff2da2-c9fd-4d28-ab8e-ce4c3836561d-00-3ume8ota3cp83.riker.replit.dev"
SSH_KEY="~/.ssh/replit_staging"

# 1 · ensure a clean target dir
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$REMOTE" \
  'rm -rf ~/workspace/PACKS && mkdir -p ~/workspace/PACKS'

for TGZ in "$OUT_DIR"/*.tgz; do
  FILE_NAME=$(basename "$TGZ")
  echo "🚚  Uploading $FILE_NAME …"
  cat "$TGZ" | ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no \
       "$REMOTE" "cat > ~/workspace/PACKS$FILE_NAME"
done

echo "✅ All tarballs uploaded to ~/workspace on Replit."
echo "On Replit run:  pnpm i -g ~/workspace/Packs/*.tgz"

echo "✅  All n8n packages published to GitHub Packages"
