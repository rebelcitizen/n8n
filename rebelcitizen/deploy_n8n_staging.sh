#!/bin/bash
set -e

ROOT_DIR="$(pwd)"
OUT_DIR="$ROOT_DIR/Packs"
# Variables
REPLIT_USER="d2ff2da2-c9fd-4d28-ab8e-ce4c3836561d"
REPLIT_HOST="d2ff2da2-c9fd-4d28-ab8e-ce4c3836561d-00-3ume8ota3cp83.riker.replit.dev"
REPLIT_TARGET="/home/runner/workspace"
SSH_KEY="$HOME/.ssh/replit_staging"

# Step 1: Build n8n (from repo root)
echo "Running build..."
pnpm install
pnpm build


echo "⏳ Packing n8n workspaces…"
rm -rf "$OUT_DIR" && mkdir -p "$OUT_DIR"

# Step 2: Pack the CLI package
echo "Packing n8n..."

npm pack --workspaces --include-workspace-root \
         --pack-destination "$OUT_DIR" > /dev/null

# Step 3: Copy the package to Replit
echo "Copying packages to Replit..."

for TGZ in "$OUT_DIR"/*.tgz; do
  FILE_NAME=$(basename "$TGZ")
  echo "🚚  Uploading $FILE_NAME …"
  cat "$TGZ" | ssh -i "$SSH_KEY" -p 22 \
       "$REPLIT_USER@$REPLIT_HOST" "cat > ~/workspace/$FILE_NAME"
done

#cat "packages/cli/$PACKAGE_FILE" | ssh -i "$SSH_KEY" -p 22 "$REPLIT_USER@$REPLIT_HOST" "cat > $REPLIT_TARGET/$PACKAGE_FILE"

#scp -i "$SSH_KEY" "packages/cli/$PACKAGE_FILE" "${REPLIT_USER}@${REPLIT_HOST}:${REPLIT_TARGET}/"
echo "✅ All tarballs uploaded to ~/workspace on Replit."
echo "On Replit run:  npm i -g ~/workspace/n8n-*.tgz"
#echo "Done. Package uploaded as ${PACKAGE_FILE} to ${REPLIT_TARGET} on Replit."
