#!/usr/bin/env bash
set -e

until nc -z spanner 9010; do
  sleep 1
done

gcloud config set auth/disable_credentials true
gcloud config set project "$PROJECT_ID"

gcloud spanner instances create "$SPANNER_INSTANCE" \
  --config=emulator-config \
  --nodes=1 || true

gcloud spanner databases create "$SPANNER_DATABASE" \
  --instance="$SPANNER_INSTANCE" || true