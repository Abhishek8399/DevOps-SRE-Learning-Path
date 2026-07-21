#!/usr/bin/env bash

set -Eeuo pipefail

readonly LAB_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONTAINER_NAME="devops-sre-p1-enospc"
readonly CONTAINER_LABEL="phase01-lesson01"
readonly IMAGE_NAME="devops-sre-training/enospc-lab:2"
readonly BASE_IMAGE="busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662"

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    printf 'docker command is unavailable in this WSL distribution\n' >&2
    return 1
  fi

  if ! timeout 20 docker info >/dev/null 2>&1; then
    printf 'Docker daemon is unavailable; start Docker Desktop and enable Ubuntu WSL integration\n' >&2
    return 1
  fi
}

container_exists() {
  docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1
}

container_label() {
  docker container inspect \
    --format '{{ index .Config.Labels "devops-sre.training" }}' \
    "$CONTAINER_NAME"
}

require_owned_container() {
  if ! container_exists; then
    printf 'Lab container does not exist; run: bash lab.sh setup\n' >&2
    return 1
  fi

  local actual_label
  actual_label="$(container_label)"
  if [[ "$actual_label" != "$CONTAINER_LABEL" ]]; then
    printf 'Refusing operation: container label mismatch for %s\n' "$CONTAINER_NAME" >&2
    return 1
  fi
}

remove_owned_container() {
  if ! container_exists; then
    return 0
  fi

  require_owned_container
  docker container rm --force "$CONTAINER_NAME" >/dev/null
}

setup_lab() {
  require_docker

  if container_exists; then
    printf 'Refusing to replace existing container %s; run cleanup explicitly first\n' "$CONTAINER_NAME" >&2
    return 1
  fi

  if ! docker image inspect "$BASE_IMAGE" >/dev/null 2>&1; then
    printf 'Pinned BusyBox image is missing. Run this networked bootstrap once:\n' >&2
    printf '  docker pull busybox:1.36.1\n' >&2
    return 1
  fi

  docker build \
    --pull=false \
    --network=none \
    --tag "$IMAGE_NAME" \
    --file "$LAB_DIRECTORY/Dockerfile" \
    "$LAB_DIRECTORY" >/dev/null

  local created=false
  rollback_failed_setup() {
    if [[ "$created" == true ]]; then
      remove_owned_container || true
    fi
  }
  trap rollback_failed_setup ERR

  docker run \
    --detach \
    --name "$CONTAINER_NAME" \
    --user 65534:65534 \
    --label "devops-sre.training=$CONTAINER_LABEL" \
    --network none \
    --read-only \
    --cap-drop ALL \
    --security-opt no-new-privileges=true \
    --pids-limit 64 \
    --memory 128m \
    --memory-swap 128m \
    --cpus 0.5 \
    --restart no \
    --stop-timeout 3 \
    --tmpfs /var:rw,nosuid,nodev,noexec,size=16m,nr_inodes=512,uid=65534,gid=65534,mode=0755 \
    --tmpfs /run:rw,nosuid,nodev,noexec,size=1m,nr_inodes=64,uid=65534,gid=65534,mode=0755 \
    --health-cmd 'test -f /run/lab-ready' \
    --health-interval 2s \
    --health-timeout 1s \
    --health-retries 15 \
    "$IMAGE_NAME" >/dev/null
  created=true

  local attempt state
  for attempt in {1..30}; do
    state="$(docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME")"
    if [[ "$state" != "running" ]]; then
      printf 'Lab fixture exited before becoming ready\n' >&2
      docker container logs "$CONTAINER_NAME" >&2 || true
      return 1
    fi

    if docker container exec "$CONTAINER_NAME" test -f /run/lab-ready; then
      trap - ERR
      printf 'incident_ready=true container=%s\n' "$CONTAINER_NAME"
      return 0
    fi
    sleep 1
  done

  printf 'Lab fixture did not become ready within 30 seconds\n' >&2
  return 1
}

show_status() {
  require_docker
  require_owned_container
  docker container inspect \
    --format 'name={{.Name}} state={{.State.Status}} health={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}} image={{.Config.Image}} user={{if .Config.User}}{{.Config.User}}{{else}}root{{end}} network={{.HostConfig.NetworkMode}} readonly={{.HostConfig.ReadonlyRootfs}}' \
    "$CONTAINER_NAME"
}

open_shell() {
  require_docker
  require_owned_container

  local configured_user state
  state="$(docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME")"
  if [[ "$state" != "running" ]]; then
    printf 'Lab container is not running\n' >&2
    return 1
  fi

  configured_user="$(docker container inspect --format '{{.Config.User}}' "$CONTAINER_NAME")"
  if [[ "$configured_user" != "65534:65534" ]]; then
    printf 'Refusing shell: lab container default user is %s; run cleanup and setup to rebuild the hardened lab\n' \
      "${configured_user:-root}" >&2
    return 1
  fi

  docker container exec --interactive --tty --user 65534:65534 "$CONTAINER_NAME" sh
}

cleanup_lab() {
  require_docker
  if ! container_exists; then
    printf 'cleanup_verified=true container_absent=%s\n' "$CONTAINER_NAME"
    return 0
  fi

  remove_owned_container
  if container_exists; then
    printf 'Cleanup verification failed for %s\n' "$CONTAINER_NAME" >&2
    return 1
  fi
  printf 'cleanup_verified=true container_absent=%s\n' "$CONTAINER_NAME"
}

usage() {
  printf 'Usage: bash lab.sh {setup|status|shell|cleanup}\n' >&2
}

main() {
  local command="${1:-}"
  case "$command" in
    setup) setup_lab ;;
    status) show_status ;;
    shell) open_shell ;;
    cleanup) cleanup_lab ;;
    *) usage; return 2 ;;
  esac
}

main "$@"
