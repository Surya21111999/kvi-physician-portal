#!/usr/bin/env bash
# Deploy to GitHub Pages: commit local changes and push to origin.
# Usage (works without execute bit):
#   bash deploy.sh
#   bash deploy.sh "Fix nav links on for-physicians"
#
# Optional — enable ./deploy.sh:
#   chmod +x deploy.sh
#
# Optional: copy brochure HTML/CSS from another folder before git steps:
#   export KVI_SYNC_FROM="/Users/nisha/Downloads/kvi home/physicians"
#   bash deploy.sh "Sync from Downloads copy"
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "deploy.sh: not a git repository (expected ${ROOT})" >&2
  exit 1
fi

if [[ -n "${KVI_SYNC_FROM:-}" ]]; then
  if [[ ! -d "$KVI_SYNC_FROM" ]]; then
    echo "deploy.sh: KVI_SYNC_FROM is not a directory: $KVI_SYNC_FROM" >&2
    exit 1
  fi
  echo "Syncing HTML from: $KVI_SYNC_FROM"
  shopt -s nullglob
  for f in "$KVI_SYNC_FROM"/*.html; do
    base="$(basename "$f")"
    cp -f "$f" "$ROOT/$base"
    echo "  copied $base"
  done
  shopt -u nullglob
fi

COMMIT_MSG="${1:-Deploy physician portal $(date -u +%Y-%m-%dT%H:%MZ)}"

git add -A

if git diff --cached --quiet; then
  echo "Nothing to commit (working tree matches HEAD)."
  exit 0
fi

git commit -m "$COMMIT_MSG"

BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
if [[ -z "$BRANCH" ]]; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
fi

git push -u origin "$BRANCH"

echo "Pushed branch '$BRANCH' to origin."
echo "Pages (after build): https://surya21111999.github.io/kvi-physician-portal/"
echo "Hard-refresh the site if you still see old assets."
