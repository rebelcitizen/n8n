#!/usr/bin/env bash
set -euo pipefail


OUT_DIR="$(pwd)/Packs"
REMOTE="${DEPLOYMENT_USER}@${DEPLOYMENT_HOST}"

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
#OUT_DIR="./Packs"
rm -rf "$OUT_DIR" && mkdir -p "$OUT_DIR"

find . -type f -name '*.tgz' -newer "$MARKER" -print0 \
  | while IFS= read -r -d '' pkg ; do
        echo "→  $(basename "$pkg")"
        mv "$pkg" "$OUT_DIR"/
    done

rm "$MARKER"


# 1 · ensure a clean target dir
ssh "$REMOTE" "rm -rf ${DEPLOYMENT_FOLDER} && mkdir -p ${DEPLOYMENT_FOLDER}"

for TGZ in "$OUT_DIR"/*.tgz; do
  FILE_NAME=$(basename "$TGZ")
  echo "🚚  Uploading $FILE_NAME …"
  cat "$TGZ" | ssh "$REMOTE" "cat > ${DEPLOYMENT_FOLDER}$FILE_NAME"
done

echo "✅ All tarballs uploaded to ${DEPLOYMENT_FOLDER} on ${DEPLOYMENT_HOST}."

