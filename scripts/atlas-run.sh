#!/usr/bin/env sh

set -e

SERVICE=atlas-run

. /log.sh

log "Checking init migration"

if [ -z "$(ls -A /db/migrations 2>/dev/null)" ]; then
  log "Creating init migration"

  atlas migrate diff init \
    --env local \
    --to file://db/schema.sql
fi

log "Applying migrations"

atlas migrate apply --env local