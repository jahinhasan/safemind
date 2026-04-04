Quick transfer & bootstrap

Goal: push this project to GitHub from this laptop, then clone & setup on another laptop with one command.

1) From your current laptop — push repo to GitHub (one command):

   ./scripts/push_to_github.sh <your-account-or-org>/<repo-name>

   - If you have the GitHub CLI (`gh`) installed and authenticated, the script will create the repo and push.
   - Without `gh`, create the repo in GitHub first, then run the script with the repo name.

2) On the other laptop — clone and run bootstrap (single command):

   git clone https://github.com/<your-account-or-org>/<repo-name>.git && cd <repo-name> && ./scripts/bootstrap.sh

Or, if you prefer to download and run bootstrap directly (one-liner):

   bash -c "$(curl -fsSL https://raw.githubusercontent.com/<your-account-or-org>/<repo-name>/main/scripts/bootstrap.sh)"

Notes & requirements:
- The target machine needs `git` and `flutter` installed and on PATH.
- Firebase CLI is optional; if your app uses Firebase you should run `firebase login` and `firebase use --add safemind-7d84c`.
- The `firestore.indexes.json` file is included; deploy it with `firebase deploy --only firestore:indexes` once logged in.
- The bootstrap script runs `flutter pub get` and prints next steps.
- The bootstrap script runs `flutter pub get` and prints next steps.

Windows support
----------------
- A PowerShell bootstrap script `scripts/bootstrap.ps1` is included for Windows.
- To run on Windows (PowerShell):

  1) Open PowerShell as Administrator (or set ExecutionPolicy for the process):

     Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

  2) Run the bootstrap script from the repo root:

     .\scripts\bootstrap.ps1

Notes for Windows:
- The script checks for `git` and `flutter` on PATH. Install Git for Windows and Flutter first.
- `./scripts/push_to_github.sh` can be used from Git Bash or WSL to create and push a repo; with PowerShell you can use the `gh` CLI if installed.

If you want, I can run the push script for you from this machine — tell me the GitHub repo name (owner/repo) to push to.