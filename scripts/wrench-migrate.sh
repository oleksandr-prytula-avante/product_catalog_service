#!/usr/bin/env sh
set -e

SERVICE=wrench-migrate

. /scripts/log.sh

log "Creating database from schema.sql"

wrench create --directory ./db

log "Applying migrations"

wrench migrate up --directory ./db