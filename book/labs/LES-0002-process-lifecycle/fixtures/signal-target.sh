#!/usr/bin/env bash

set -Eeuo pipefail
umask 077
readonly LAB_TOKEN="$1"
readonly EVENT_FILE="$2"
on_term() {
  printf 'event=term_received token=%s pid=%s\n' "$LAB_TOKEN" "$$" >> "$EVENT_FILE"
  exit 0
}
trap on_term TERM
printf 'event=ready token=%s pid=%s\n' "$LAB_TOKEN" "$$" >> "$EVENT_FILE"
while :; do
  sleep 1 &
  wait "$!" || true
done
