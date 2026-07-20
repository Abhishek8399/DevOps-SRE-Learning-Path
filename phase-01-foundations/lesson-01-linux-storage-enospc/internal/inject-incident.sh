#!/bin/sh

set -eu
export LC_ALL=C

upload_directory=/var/lib/api/uploads
object_directory="$upload_directory/.runtime/cache/objects"
payload_file="$upload_directory/.retained-data"
api_log=/var/log/api/api.log
deployment_log=/var/log/api/deploy.log
write_error=/run/write-error

mkdir -p "$object_directory" /var/log/api /var/lib/api/releases
: >"$payload_file"
: >"$api_log"
: >"$deployment_log"
: >"$write_error"

incident_epoch="$(date +%s)"
deployment_epoch="$((incident_epoch - 840))"
printf 'epoch=%s status=success release=2026.07.20.1\n' "$deployment_epoch" >"$deployment_log"

dd if=/dev/zero of="$payload_file" bs=1M count=7 2>/dev/null

file_index=0
while [ "$file_index" -lt 2048 ]; do
  candidate_file="$(printf '%s/%08d.part' "$object_directory" "$file_index")"
  if ( : >"$candidate_file" ) 2>/dev/null; then
    file_index="$((file_index + 1))"
  else
    break
  fi
done

if [ "$file_index" -eq 2048 ]; then
  printf 'fixture_error=inode_limit_not_reached\n' >&2
  exit 1
fi

used_percent() {
  df -P /var | awk 'NR == 2 { gsub(/%/, "", $5); print $5 }'
}

current_percent="$(used_percent)"
while [ "$current_percent" -lt 48 ]; do
  dd if=/dev/zero bs=4096 count=1 2>/dev/null >>"$payload_file"
  current_percent="$(used_percent)"
done

if [ "$current_percent" -ne 48 ]; then
  printf 'fixture_error=unexpected_block_use_percent value=%s\n' "$current_percent" >&2
  exit 1
fi

if ( : >"$upload_directory/7f9c.tmp" ) 2>"$write_error"; then
  printf 'fixture_error=target_write_succeeded\n' >&2
  exit 1
fi

printf 'epoch=%s level=ERROR operation=upload path=%s error="No space left on device"\n' \
  "$incident_epoch" "$upload_directory/7f9c.tmp" >>"$api_log"

inode_percent="$(df -i /var | awk 'NR == 2 { gsub(/%/, "", $5); print $5 }')"
if [ "$inode_percent" -ne 100 ]; then
  printf 'fixture_error=unexpected_inode_use_percent value=%s\n' "$inode_percent" >&2
  exit 1
fi

if ! grep -q 'No space left on device' "$write_error"; then
  printf 'fixture_error=expected_kernel_error_missing\n' >&2
  exit 1
fi

: >/run/lab-ready
printf 'incident_ready=true\n'

while :; do
  sleep 3600
done
