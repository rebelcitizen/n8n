#!/usr/bin/env bash
# Sync ./Packs/*.tgz → <pkgDir>/package.json dependencies + pnpm.overrides
# Usage:  sync-packs.sh [<folder-with-package.json>]
# -------------------------------------------------------------
set -euo pipefail

# -------- configuration --------
export PACK_DIR="${PACK_DIR:-./Packs}"          # where the tarballs live
export PKG_DIR="${1:-.}"                        # first arg or current dir
export PKG_FILE="$PKG_DIR/package.json"
# --------------------------------

if [[ ! -d "$PACK_DIR" ]]; then
  echo "✖  Folder '$PACK_DIR' not found" >&2; exit 1
fi
if [[ ! -f "$PKG_FILE" ]]; then
  echo "✖  '$PKG_FILE' not found" >&2; exit 1
fi

echo "✔  '$PKG_FILE' '$PKG_DIR'" 

node --input-type=module <<'NODE'
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const packDir = process.env.PACK_DIR ?? './Packs';
const pkgDir  = process.env.PKG_DIR  ?? '.';
const pkgFile = path.join(pkgDir, 'package.json');
const pkgJson = JSON.parse(fs.readFileSync(pkgFile, 'utf8'));

const tgzs = fs.readdirSync(packDir).filter(f => f.endsWith('.tgz'));
if (!tgzs.length) {
  console.log('No .tgz files found – nothing to do.');
  process.exit(0);
}

for (const f of tgzs) {
  // n8n-<name>-<version>.tgz  OR  n8n-<version>.tgz
  const m = /^n8n(?:-(.+?))?-([\d.]+.*)\.tgz$/.exec(f);
  if (!m) continue;                         // skip unrecognised files

  const pkgName = m[1] ? `@n8n/${m[1]}` : 'n8n';
  const absPath = path.resolve(packDir, f);
  const relPath = path.relative(pkgDir, absPath).replace(/\\/g, '/');
  const spec    = `file:${relPath}`;

  // dependencies
  pkgJson.dependencies            = pkgJson.dependencies || {};
  pkgJson.dependencies[pkgName]   = spec;

  // pnpm.overrides
  pkgJson.pnpm                    = pkgJson.pnpm || {};
  pkgJson.pnpm.overrides          = pkgJson.pnpm.overrides || {};
  pkgJson.pnpm.overrides[pkgName] = spec;
}

fs.writeFileSync(pkgFile, JSON.stringify(pkgJson, null, 2) + '\n');
console.log(`✔  Updated ${pkgFile} with ${tgzs.length} local pack(s).`);
NODE
