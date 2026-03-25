#!/usr/bin/env sh

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$SERVICE] $1"
}

error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$SERVICE][ERROR] $1" >&2
}