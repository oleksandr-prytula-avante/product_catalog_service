#!/usr/bin/env sh
set -e

SERVICE=spanner-init

. /log.sh

log "Waiting for Spanner emulator to be ready"

until nc -z spanner 9010; do
  sleep 1
done

log "Spanner emulator is ready"

gcloud config set auth/disable_credentials true
gcloud config set project "$PROJECT_ID"

log "Creating Spanner instance and database"

gcloud spanner instances create "$SPANNER_INSTANCE" \
  --config=emulator-config \
  --nodes=1 || true

log "Waiting for Spanner instance to be ready"

until gcloud spanner instances describe "$SPANNER_INSTANCE" > /dev/null 2>&1; do
  sleep 1
done

log "Spanner instance is ready"

gcloud spanner databases create "$SPANNER_DATABASE" \
  --instance="$SPANNER_INSTANCE" || true
  
log "Spanner database is ready"