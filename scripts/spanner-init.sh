#!/usr/bin/env sh
set -e

SERVICE=spanner-init

. /scripts/log.sh

log "Spanner emulator host: $SPANNER_EMULATOR_HOST and API endpoint: $CLOUDSDK_API_ENDPOINT_OVERRIDES_SPANNER"

gcloud config set auth/disable_credentials true
gcloud config set project "$SPANNER_PROJECT_ID"

log "Creating Spanner instance and database"

gcloud spanner instances create "$SPANNER_INSTANCE_ID" \
  --project="$SPANNER_PROJECT_ID" \
  --description="Spanner instance $SPANNER_INSTANCE_ID in project $SPANNER_PROJECT_ID" \
  --config=emulator-config \
  --nodes=1 || true

log "Waiting for Spanner instance $SPANNER_INSTANCE_ID to be ready"

until gcloud spanner instances describe "$SPANNER_INSTANCE_ID" > /dev/null 2>&1; do
  sleep 1
done

log "Spanner instance $SPANNER_INSTANCE_ID in project $SPANNER_PROJECT_ID is ready"