#!/usr/bin/env bash
set -euo pipefail

REPO_ARG=${1:-}

if [ -z "$REPO_ARG" ]; then
  echo "Usage: $0 owner/repo"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git not found. Install git first." >&2
  exit 1
fi

if [ ! -d .git ]; then
  git init
  git add -A
  git commit -m "Initial import of SafeMind app"
fi

# If gh CLI is available, use it to create the remote repo and push
if command -v gh >/dev/null 2>&1; then
  echo "Using GitHub CLI to create and push repo..."
  # try to create repo; if exists, skip
  if gh repo view "$REPO_ARG" >/dev/null 2>&1; then
    echo "Repository $REPO_ARG already exists. Using existing remote."
  else
    gh repo create "$REPO_ARG" --public --source=. --remote=origin --push || true
  fi
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$REPO_ARG.git"
  git branch -M main || true
  git push -u origin main --force
  echo "Pushed to https://github.com/$REPO_ARG"
  exit 0
fi

# Without gh, set remote and push (assumes you have repo created manually)
REMOTE_URL="https://github.com/$REPO_ARG.git"
if git remote get-url origin >/dev/null 2>&1; then
  echo "origin remote already set"
else
  git remote add origin "$REMOTE_URL"
fi

git branch -M main || true

echo "Pushing to $REMOTE_URL (you may be prompted for credentials)..."
git push -u origin main --force

echo "Done. If the remote repo doesn't exist, create it on GitHub and re-run this script."