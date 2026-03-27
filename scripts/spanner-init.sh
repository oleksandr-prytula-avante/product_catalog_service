#!/usr/bin/env sh
set -e

SERVICE=spanner-init

. /scripts/log.sh

export SPANNER_EMULATOR_HOST=spanner-emulator:9010
export CLOUDSDK_API_ENDPOINT_OVERRIDES_SPANNER=http://spanner-emulator:9020/

log "Spanner emulator host: $SPANNER_EMULATOR_HOST and API endpoint: $CLOUDSDK_API_ENDPOINT_OVERRIDES_SPANNER"

gcloud config set auth/disable_credentials true
gcloud config set project "$SPANNER_PROJECT"

log "Creating Spanner instance and database"

gcloud spanner instances create "$SPANNER_INSTANCE" \
  --project="$SPANNER_PROJECT" \
  --description="Spanner instance $SPANNER_INSTANCE in project $SPANNER_PROJECT" \
  --config=emulator-config \
  --nodes=1 || true

log "Waiting for Spanner instance $SPANNER_INSTANCE to be ready"

until gcloud spanner instances describe "$SPANNER_INSTANCE" > /dev/null 2>&1; do
  sleep 1
done

log "Spanner instance $SPANNER_INSTANCE in project $SPANNER_PROJECT is ready"

gcloud spanner databases create "$SPANNER_DATABASE" \
  --project="$SPANNER_PROJECT" \
  --instance="$SPANNER_INSTANCE" || true
  
log "Spanner database $SPANNER_DATABASE in instance $SPANNER_INSTANCE is ready"