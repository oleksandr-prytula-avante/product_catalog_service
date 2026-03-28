#!/usr/bin/env sh
set -e

SERVICE=wrench-migrate

. /scripts/log.sh

log "Creating database from schema.sql"

if ! wrench create --directory ./db; then
	log "Database create failed (it may already exist), continuing with migrations"
fi

if [ ! -d ./db/migrations ]; then
	log "Migrations directory not found, creating ./db/migrations"
	mkdir -p ./db/migrations
fi

log "Applying migrations"

wrench migrate up --directory ./db