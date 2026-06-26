#!/usr/bin/env bash
# One-shot deploy of this folder to GitHub Pages (free).
# Result URL:  https://<your-gh-user>.github.io/<REPO>/
# Re-running just pushes the latest changes (safe to run many times).
set -euo pipefail
cd "$(dirname "$0")"

REPO="${1:-shadows-hide}"                 # repo name = URL slug; override: ./deploy.sh my-name
OWNER="$(gh api user -q .login)"
echo "→ Deploying ./ as  $OWNER/$REPO"

# 1) commit current state
git add -A
git commit -q -m "deploy $(date -u +%Y-%m-%dT%H:%MZ)" 2>/dev/null || echo "  (no changes to commit)"
git branch -M main

# 2) point origin at THIS owner/repo (handles switching GitHub accounts)
git remote remove origin >/dev/null 2>&1 || true
if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  git remote add origin "https://github.com/$OWNER/$REPO.git"
  git push -q -u origin main
  echo "  pushed to existing repo"
else
  gh repo create "$OWNER/$REPO" --public --source=. --remote=origin --push
  echo "  created + pushed new repo"
fi

# 3) enable GitHub Pages from main / (no-op if already enabled)
gh api -X POST "repos/$OWNER/$REPO/pages" \
   -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 \
   && echo "  GitHub Pages enabled" \
   || echo "  (Pages already enabled)"

echo ""
echo "✅ Live (after ~1 min first build):  https://$OWNER.github.io/$REPO/"
