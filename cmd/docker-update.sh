#!/usr/bin/env bash
# Update a running MyInvoice.cz Docker stack to the latest code.
#
#   1. Pulls (registry mode) or rebuilds (source mode) the app image
#   2. Restarts the stack
#   3. Waits for DB health and runs pending migrations
#
# Detects mode automatically:
#   - If `.git/` exists AND docker-compose.yml has a `build:` block → source build
#   - Otherwise → pulls pre-built image from GHCR
#
# Idempotent — safe to re-run. Volumes (DB data) persist; backup is your responsibility.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found in PATH" >&2; exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: 'docker compose' (v2) plugin required" >&2; exit 1
fi
if [[ ! -f .env ]]; then
  echo "ERROR: .env not found — run docker-install.sh first" >&2; exit 1
fi

set -a; . ./.env; set +a

# Detect mode: source build vs pre-built image from registry
MODE="registry"
if [[ -d .git ]] && grep -qE '^\s*build:' docker-compose.yml 2>/dev/null; then
  MODE="source"
fi
echo "==> Mode: ${MODE}"

# --- 1. fetch new code/image ---------------------------------------------
if [[ "${MODE}" == "source" ]]; then
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "WARN: working tree is dirty — local changes won't be pulled." >&2
    echo "      Consider 'git stash' or commit first. Continuing in 5s…" >&2
    sleep 5
  fi
  echo "==> git pull"
  git pull --ff-only
  echo "==> Rebuilding app image…"
  docker compose build --pull app
else
  echo "==> Pulling latest image from registry…"
  docker compose pull app
fi

# --- 2. restart -----------------------------------------------------------
echo "==> Restarting stack…"
docker compose up -d db app

# --- 3. wait for DB + migrate --------------------------------------------
echo "==> Waiting for database to become healthy…"
for i in {1..30}; do
  status=$(docker compose ps --format json db 2>/dev/null | grep -o '"Health":"[^"]*"' | head -1 | cut -d'"' -f4)
  if [[ "$status" == "healthy" ]]; then echo "    DB ready."; break; fi
  sleep 2
  if [[ $i -eq 30 ]]; then
    echo "ERROR: DB failed to become healthy in 60s. Check 'docker compose logs db'." >&2
    exit 1
  fi
done

echo "==> Running database migrations…"
docker compose exec -T app php api/bin/migrate.php

# --- 4. report -----------------------------------------------------------
APP_PORT="${APP_PORT:-8080}"
echo ""
echo "============================================================"
echo " Update complete. App: http://localhost:${APP_PORT}"
echo ""
echo " Tail logs:        docker compose logs -f app"
echo " Restart only:     docker compose restart app"
echo "============================================================"
