#!/usr/bin/env bash
set -euo pipefail

echo "Running SafeMind bootstrap..."

# Check for essential tools
if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: Flutter not found in PATH. Install Flutter first: https://flutter.dev/docs/get-started/install" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git not found. Install git." >&2
  exit 1
fi

# Optional tools
if command -v gh >/dev/null 2>&1; then
  echo "gh: GitHub CLI is available"
fi
if command -v firebase >/dev/null 2>&1; then
  echo "firebase: CLI is available"
fi

echo "Installing Dart/Flutter packages..."
flutter pub get

# Provide Firebase setup hints
cat <<'EOF'

Next steps you may need to run manually:

1) If you use Firebase services, login and configure the project:
   firebase login
   firebase use --add safemind-7d84c

2) To deploy indexes (already provided in repo):
   firebase deploy --only firestore:indexes --project safemind-7d84c

3) To run the app:
   flutter run

If you want to create a GitHub repo from this machine, run:
   ./scripts/push_to_github.sh owner/repo

EOF

echo "Bootstrap complete."