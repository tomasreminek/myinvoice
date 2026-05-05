# Update a running MyInvoice.cz Docker stack to the latest code.
#
#   1. Pulls (registry mode) or rebuilds (source mode) the app image
#   2. Restarts the stack
#   3. Waits for DB health and runs pending migrations
#
# Detects mode automatically:
#   - If `.git/` exists AND docker-compose.yml has a `build:` block -> source build
#   - Otherwise -> pulls pre-built image from GHCR
#
# Idempotent — safe to re-run. Volumes (DB data) persist; backup is your responsibility.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $ProjectRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "docker not found in PATH"
}
& docker compose version > $null 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error "'docker compose' (v2) plugin required" }
if (-not (Test-Path .env)) { Write-Error ".env not found - run docker-install.ps1 first" }

# Load .env into hashtable
$envVars = @{}
Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*([A-Z_]+)\s*=\s*(.*)\s*$') { $envVars[$Matches[1]] = $Matches[2] }
}

# Detect mode: source build vs pre-built image from registry
$mode = 'registry'
if ((Test-Path .git) -and (Select-String -Path docker-compose.yml -Pattern '^\s*build:' -Quiet)) {
    $mode = 'source'
}
Write-Host "==> Mode: $mode"

# --- 1. fetch new code/image ---------------------------------------------
if ($mode -eq 'source') {
    $dirty = & git status --porcelain
    if ($dirty) {
        Write-Warning "Working tree is dirty - local changes won't be pulled."
        Write-Warning "Consider 'git stash' or commit first. Continuing in 5s..."
        Start-Sleep -Seconds 5
    }
    Write-Host "==> git pull"
    & git pull --ff-only
    if ($LASTEXITCODE -ne 0) { Write-Error "git pull failed" }
    Write-Host "==> Rebuilding app image..."
    & docker compose build --pull app
    if ($LASTEXITCODE -ne 0) { Write-Error "docker compose build failed" }
} else {
    Write-Host "==> Pulling latest image from registry..."
    & docker compose pull app
    if ($LASTEXITCODE -ne 0) { Write-Error "docker compose pull failed" }
}

# --- 2. restart ----------------------------------------------------------
Write-Host "==> Restarting stack..."
& docker compose up -d db app
if ($LASTEXITCODE -ne 0) { Write-Error "docker compose up failed" }

# --- 3. wait for DB + migrate -------------------------------------------
Write-Host "==> Waiting for database to become healthy..."
$ready = $false
for ($i = 1; $i -le 30; $i++) {
    $json = & docker compose ps --format json db 2>$null
    if ($json -match '"Health":"healthy"') { $ready = $true; Write-Host "    DB ready."; break }
    Start-Sleep -Seconds 2
}
if (-not $ready) {
    Write-Error "DB failed to become healthy in 60s. Check 'docker compose logs db'."
}

Write-Host "==> Running database migrations..."
& docker compose exec -T app php api/bin/migrate.php
if ($LASTEXITCODE -ne 0) { Write-Error "Migrations failed" }

# --- 4. report -----------------------------------------------------------
$port = $envVars.APP_PORT
if (-not $port) { $port = '8080' }
Write-Host ""
Write-Host "============================================================"
Write-Host " Update complete. App: http://localhost:$port"
Write-Host ""
Write-Host " Tail logs:        docker compose logs -f app"
Write-Host " Restart only:     docker compose restart app"
Write-Host "============================================================"
