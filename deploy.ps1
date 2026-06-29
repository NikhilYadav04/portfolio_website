# ============================================================
#  deploy.ps1 — Portfolio GitHub Pages Deploy Script
#  Usage: Right-click > "Run with PowerShell"  OR  .\deploy.ps1
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Step($msg) {
    Write-Host "`n>>> $msg" -ForegroundColor Cyan
}

function Write-Success($msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}

function Write-Fail($msg) {
    Write-Host "[FAIL] $msg" -ForegroundColor Red
}

# --- Config ---
$BASE_HREF    = "/portfolio_website/"
$REMOTE       = "origin"
$MAIN_BRANCH  = "master"
$DEPLOY_BRANCH = "gh-pages"
$BUILD_DIR    = "build\web"

# -------------------------------------------------------
# STEP 1: Commit any uncommitted changes on master
# -------------------------------------------------------
Write-Step "Checking for uncommitted changes..."

$status = git status --porcelain
if ($status) {
    $msg = Read-Host "  You have uncommitted changes. Enter a commit message (or press Enter for default)"
    if ([string]::IsNullOrWhiteSpace($msg)) {
        $msg = "Update portfolio"
    }
    git add .
    git commit -m $msg
    Write-Success "Committed: '$msg'"
} else {
    Write-Success "Nothing to commit, working tree clean"
}

# -------------------------------------------------------
# STEP 2: Push master to GitHub
# -------------------------------------------------------
Write-Step "Pushing $MAIN_BRANCH to GitHub..."
git push $REMOTE $MAIN_BRANCH
Write-Success "Pushed $MAIN_BRANCH"

# -------------------------------------------------------
# STEP 3: Build Flutter web
# -------------------------------------------------------
Write-Step "Building Flutter web (base-href: $BASE_HREF)..."
flutter build web --release --base-href $BASE_HREF
Write-Success "Build complete → $BUILD_DIR"

# -------------------------------------------------------
# STEP 4: Deploy build/web to gh-pages branch
# -------------------------------------------------------
Write-Step "Deploying to $DEPLOY_BRANCH branch..."

$TEMP_BRANCH = "gh-pages-deploy-temp"

git checkout --orphan $TEMP_BRANCH
git rm -rf . --quiet

# Copy built files to root
Copy-Item -Path "$BUILD_DIR\*" -Destination "." -Recurse -Force

$deployDate = Get-Date -Format "yyyy-MM-dd HH:mm"
git add .
git commit -m "Deploy: $deployDate"
git push $REMOTE "${TEMP_BRANCH}:${DEPLOY_BRANCH}" --force

# -------------------------------------------------------
# STEP 5: Go back to master and clean up
# -------------------------------------------------------
git checkout $MAIN_BRANCH
git branch -D $TEMP_BRANCH

Write-Success "Deployed to $DEPLOY_BRANCH!"

# -------------------------------------------------------
# DONE
# -------------------------------------------------------
Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "  DEPLOYED!  Wait ~2 min then visit:" -ForegroundColor Yellow
Write-Host "  https://nikhilyadav04.github.io/portfolio_website/" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to close"
