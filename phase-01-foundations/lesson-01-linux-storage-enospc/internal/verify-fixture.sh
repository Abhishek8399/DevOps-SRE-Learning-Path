#!/usr/bin/env bash

set -Eeuo pipefail

readonly CONTAINER_NAME="${CONTAINER_NAME:-devops-sre-p1-enospc}"
readonly EXPECTED_LABEL="${EXPECTED_LABEL:-phase01-lesson01}"

fail() {
  printf 'fixture_validation_failed=%s\n' "$1" >&2
  exit 1
}

docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1 || fail "container_missing"

actual_label="$(docker container inspect --format '{{ index .Config.Labels "devops-sre.training" }}' "$CONTAINER_NAME")"
[[ "$actual_label" == "$EXPECTED_LABEL" ]] || fail "label_mismatch"

state="$(docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME")"
[[ "$state" == "running" ]] || fail "container_not_running"

configured_user="$(docker container inspect --format '{{.Config.User}}' "$CONTAINER_NAME")"
[[ "$configured_user" == "65534:65534" ]] || fail "default_user_not_unprivileged"

runtime_uid="$(docker container exec "$CONTAINER_NAME" id -u)"
runtime_gid="$(docker container exec "$CONTAINER_NAME" id -g)"
[[ "$runtime_uid" == "65534" ]] || fail "runtime_uid_not_unprivileged"
[[ "$runtime_gid" == "65534" ]] || fail "runtime_gid_not_unprivileged"

docker container exec "$CONTAINER_NAME" test -f /run/lab-ready || fail "readiness_marker_missing"

block_line="$(docker container exec "$CONTAINER_NAME" df -P /var | tail -n 1)"
block_percent="$(awk '{ gsub(/%/, "", $5); print $5 }' <<<"$block_line")"
[[ "$block_percent" == "48" ]] || fail "block_use_not_48"

inode_line="$(docker container exec "$CONTAINER_NAME" df -i /var | tail -n 1)"
inode_percent="$(awk '{ gsub(/%/, "", $5); print $5 }' <<<"$inode_line")"
[[ "$inode_percent" == "100" ]] || fail "inode_use_not_100"

docker container exec "$CONTAINER_NAME" grep -q 'No space left on device' /run/write-error \
  || fail "kernel_enospc_evidence_missing"

readonly_root="$(docker container inspect --format '{{.HostConfig.ReadonlyRootfs}}' "$CONTAINER_NAME")"
[[ "$readonly_root" == "true" ]] || fail "root_filesystem_not_read_only"

network_mode="$(docker container inspect --format '{{.HostConfig.NetworkMode}}' "$CONTAINER_NAME")"
[[ "$network_mode" == "none" ]] || fail "network_not_disabled"

cap_drop="$(docker container inspect --format '{{json .HostConfig.CapDrop}}' "$CONTAINER_NAME")"
[[ "$cap_drop" == '["ALL"]' ]] || fail "capabilities_not_dropped"

tmpfs_configuration="$(docker container inspect --format '{{json .HostConfig.Tmpfs}}' "$CONTAINER_NAME")"
[[ "$tmpfs_configuration" == *'nr_inodes=512'* ]] || fail "inode_limit_missing"
[[ "$tmpfs_configuration" == *'size=16m'* ]] || fail "byte_limit_missing"
[[ "$tmpfs_configuration" == *'uid=65534'* ]] || fail "tmpfs_uid_missing"
[[ "$tmpfs_configuration" == *'gid=65534'* ]] || fail "tmpfs_gid_missing"

printf 'fixture_valid=true block_use_percent=%s inode_use_percent=%s runtime_uid=%s\n' \
  "$block_percent" "$inode_percent" "$runtime_uid"
