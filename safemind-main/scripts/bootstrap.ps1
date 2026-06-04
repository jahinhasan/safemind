<#
PowerShell bootstrap for SafeMind
Run (from repo root):
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  .\scripts\bootstrap.ps1
#>

Param()

function Fail([string]$msg) {
    Write-Error $msg
    exit 1
}

Write-Host "Running SafeMind bootstrap (PowerShell)..." -ForegroundColor Cyan

# Check for Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail "git not found. Install Git for Windows: https://git-scm.com/download/win"
}

# Check for Flutter
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Fail "Flutter not found in PATH. Install Flutter and add to PATH: https://flutter.dev/docs/get-started/install/windows"
}

# Optional checks
if (Get-Command gh -ErrorAction SilentlyContinue) { Write-Host "gh: GitHub CLI is available" }
if (Get-Command firebase -ErrorAction SilentlyContinue) { Write-Host "firebase: CLI is available" }

Write-Host "Running flutter pub get..." -ForegroundColor Green
flutter pub get

Write-Host "\nBootstrap complete. Next steps:" -ForegroundColor Cyan
Write-Host "1) If you use Firebase, install Firebase CLI and login:" -ForegroundColor Yellow
Write-Host "   npm install -g firebase-tools" -ForegroundColor Gray
Write-Host "   firebase login" -ForegroundColor Gray
Write-Host "   firebase use --add safemind-7d84c" -ForegroundColor Gray
Write-Host "   firebase deploy --only firestore:indexes --project safemind-7d84c" -ForegroundColor Gray

Write-Host "2) To run the app:" -ForegroundColor Yellow
Write-Host "   flutter run" -ForegroundColor Gray

Write-Host "3) To push to GitHub from this machine (create repo):" -ForegroundColor Yellow
Write-Host "   ./scripts/push_to_github.sh <owner>/<repo>  # requires Git Bash or WSL, or run in PowerShell with bash if available" -ForegroundColor Gray

Write-Host "If you need help with any step, paste errors here and I'll help." -ForegroundColor Cyan
