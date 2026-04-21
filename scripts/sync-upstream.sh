#!/usr/bin/env bash
# Sync upstream reference repo (shrimbly/node-banana) -> origin/develop
#
# Usage:
#   bash scripts/sync-upstream.sh            # check + push if updates
#   bash scripts/sync-upstream.sh --check    # only show diff, do not push
#
# Requires remote "reference" = https://github.com/shrimbly/node-banana.git
# If missing, the script adds it automatically.

set -e

REFERENCE_URL="https://github.com/shrimbly/node-banana.git"
BRANCH="develop"
CHECK_ONLY=false

[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

# Ensure reference remote exists
if ! git remote | grep -q '^reference$'; then
  echo "[+] Adding reference remote: $REFERENCE_URL"
  git remote add reference "$REFERENCE_URL"
fi

echo "[+] Fetching reference and origin..."
git fetch reference --tags
git fetch origin

NEW_COMMITS=$(git log --oneline "origin/$BRANCH..reference/$BRANCH" 2>/dev/null | wc -l | tr -d ' ')

if [[ "$NEW_COMMITS" -eq 0 ]]; then
  echo "[=] origin/$BRANCH is already up-to-date with reference/$BRANCH. Nothing to do."
  exit 0
fi

echo "[!] reference/$BRANCH has $NEW_COMMITS new commit(s) ahead of origin/$BRANCH:"
echo "--------------------------------------------------------------------"
git log --oneline "origin/$BRANCH..reference/$BRANCH" | head -30
echo "--------------------------------------------------------------------"

if $CHECK_ONLY; then
  echo "[i] --check mode: no push performed."
  exit 0
fi

echo "[+] Pushing reference/$BRANCH -> origin/$BRANCH ..."
git push origin "refs/remotes/reference/$BRANCH:refs/heads/$BRANCH"

echo "[OK] origin/$BRANCH synced successfully."
