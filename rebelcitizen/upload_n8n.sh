#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="./Packs"
mkdir -p "$OUT_DIR"

REMOTE="d2ff2da2-c9fd-4d28-ab8e-ce4c3836561d@d2ff2da2-c9fd-4d28-ab8e-ce4c3836561d-00-3ume8ota3cp83.riker.replit.dev"
SSH_KEY="~/.ssh/replit_staging"

for TGZ in "$OUT_DIR"/*.tgz; do
  FILE_NAME=$(basename "$TGZ")
  echo "🚚  Uploading $FILE_NAME …"
  cat "$TGZ" | ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no \
       "$REMOTE" "cat > ~/workspace/Packs/$FILE_NAME"
done

echo "✅ All tarballs uploaded to ~/workspace on Replit."
echo "On Replit run:  npm i -g ~/workspace/n8n-*.tgz"

