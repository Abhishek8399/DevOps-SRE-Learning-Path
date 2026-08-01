#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LAB_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONTAINER_NAME="devops-sre-p1-enospc"
readonly CONTAINER_LABEL="phase01-lesson01"
readonly IMAGE_NAME="devops-sre-training/enospc-lab:2"
readonly LEGACY_IMAGE_NAME="devops-sre-training/enospc-lab:1"
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

container_profile() {
  docker container inspect \
    --format '{{ index .Config.Labels "devops-sre.training" }}|{{.Config.Image}}|{{.Config.User}}|{{.Image}}|{{json .Config.Entrypoint}}|{{.HostConfig.NetworkMode}}|{{.HostConfig.ReadonlyRootfs}}|{{.HostConfig.Privileged}}|{{json .HostConfig.CapDrop}}|{{len .HostConfig.CapAdd}}|{{json .HostConfig.SecurityOpt}}|{{.HostConfig.PidsLimit}}|{{.HostConfig.Memory}}|{{.HostConfig.MemorySwap}}|{{.HostConfig.NanoCpus}}|{{len .HostConfig.Binds}}|{{len .HostConfig.Mounts}}|{{len .HostConfig.VolumesFrom}}|{{len .HostConfig.Devices}}|{{len .HostConfig.DeviceRequests}}|{{.HostConfig.PidMode}}|{{.HostConfig.IpcMode}}|{{.HostConfig.CgroupnsMode}}|{{.HostConfig.UTSMode}}|{{.HostConfig.RestartPolicy.Name}}|{{.HostConfig.AutoRemove}}|{{len .HostConfig.Tmpfs}}|{{index .HostConfig.Tmpfs "/var"}}|{{index .HostConfig.Tmpfs "/run"}}|{{len .HostConfig.PortBindings}}|{{.HostConfig.PublishAllPorts}}' \
    "$CONTAINER_NAME"
}

csv_options_match() {
  local actual="$1"
  shift
  local -a actual_options
  local required option found

  IFS=',' read -r -a actual_options <<<"$actual"
  [[ "${#actual_options[@]}" -eq "$#" ]] || return 1
  for required in "$@"; do
    found=false
    for option in "${actual_options[@]}"; do
      if [[ "$option" == "$required" ]]; then
        found=true
        break
      fi
    done
    [[ "$found" == true ]] || return 1
  done
}

profile_matches_generation() {
  local generation="$1" require_local_image_id="$2"
  local expected_image expected_user expected_image_id
  local expected_var_options expected_run_options
  local profile label image user image_id entrypoint network readonly privileged
  local cap_drop cap_add_count security_options pids memory memory_swap nano_cpus
  local bind_count mount_count volumes_from_count device_count device_request_count
  local pid_mode ipc_mode cgroupns_mode uts_mode restart auto_remove tmpfs_count
  local var_options run_options port_binding_count publish_all_ports

  case "$generation" in
    current)
      expected_image="$IMAGE_NAME"
      expected_user='65534:65534'
      expected_var_options='rw,nosuid,nodev,noexec,size=16m,nr_inodes=512,uid=65534,gid=65534,mode=0755'
      expected_run_options='rw,nosuid,nodev,noexec,size=1m,nr_inodes=64,uid=65534,gid=65534,mode=0755'
      ;;
    legacy)
      expected_image="$LEGACY_IMAGE_NAME"
      expected_user=''
      expected_var_options='rw,nosuid,nodev,noexec,size=16m,nr_inodes=512,mode=0755'
      expected_run_options='rw,nosuid,nodev,noexec,size=1m,nr_inodes=64,mode=0755'
      ;;
    *) return 2 ;;
  esac

  profile="$(container_profile)" || return 1
  IFS='|' read -r label image user image_id entrypoint network readonly privileged \
    cap_drop cap_add_count security_options pids memory memory_swap nano_cpus \
    bind_count mount_count volumes_from_count device_count device_request_count \
    pid_mode ipc_mode cgroupns_mode uts_mode restart auto_remove tmpfs_count \
    var_options run_options port_binding_count publish_all_ports <<<"$profile"

  [[ "$label" == "$CONTAINER_LABEL" \
    && "$image" == "$expected_image" \
    && "$user" == "$expected_user" \
    && "$entrypoint" == '["/usr/local/bin/inject-incident"]' \
    && "$network" == none \
    && "$readonly" == true \
    && "$privileged" == false \
    && "$cap_drop" == '["ALL"]' \
    && "$cap_add_count" == 0 \
    && "$pids" == 64 \
    && "$memory" == 134217728 \
    && "$memory_swap" == 134217728 \
    && "$nano_cpus" == 500000000 \
    && "$bind_count" == 0 \
    && "$mount_count" == 0 \
    && "$volumes_from_count" == 0 \
    && "$device_count" == 0 \
    && "$device_request_count" == 0 \
    && "$restart" == no \
    && "$auto_remove" == false \
    && "$tmpfs_count" == 2 \
    && "$port_binding_count" == 0 \
    && "$publish_all_ports" == false ]] || return 1

  case "$security_options" in
    '["no-new-privileges"]'|'["no-new-privileges=true"]'|'["no-new-privileges:true"]') ;;
    *) return 1 ;;
  esac

  if [[ "$generation" == current ]]; then
    [[ -z "$pid_mode" \
      && "$ipc_mode" == private \
      && "$cgroupns_mode" == private \
      && -z "$uts_mode" ]] || return 1
  else
    [[ -z "$pid_mode" \
      && ( "$ipc_mode" == private || "$ipc_mode" == shareable || -z "$ipc_mode" ) \
      && ( "$cgroupns_mode" == private || "$cgroupns_mode" == host || -z "$cgroupns_mode" ) \
      && -z "$uts_mode" ]] || return 1
  fi

  local -a expected_var_array expected_run_array
  IFS=',' read -r -a expected_var_array <<<"$expected_var_options"
  IFS=',' read -r -a expected_run_array <<<"$expected_run_options"
  csv_options_match "$var_options" "${expected_var_array[@]}" || return 1
  csv_options_match "$run_options" "${expected_run_array[@]}" || return 1

  if [[ "$require_local_image_id" == true ]]; then
    expected_image_id="$(docker image inspect --format '{{.Id}}' "$expected_image" 2>/dev/null)" || return 1
    [[ "$image_id" == "$expected_image_id" ]] || return 1
  fi
}

require_owned_container() {
  if ! container_exists; then
    printf 'Lab container does not exist; run: bash lab.sh setup\n' >&2
    return 1
  fi

  if profile_matches_generation current true; then
    return 0
  fi
  if profile_matches_generation legacy false; then
    printf 'The exact legacy root-run fixture is present; run cleanup, then setup to rebuild the hardened lab\n' >&2
    return 1
  fi
  printf 'Refusing operation: %s does not match the full lesson image, mount, namespace, privilege, and resource envelope\n' \
    "$CONTAINER_NAME" >&2
  return 1
}

require_cleanup_container() {
  if profile_matches_generation current false \
    || profile_matches_generation legacy false; then
    return 0
  fi
  printf 'Refusing cleanup: %s is neither the current fixture nor the full legacy lesson envelope\n' \
    "$CONTAINER_NAME" >&2
  return 1
}

remove_owned_container() {
  if ! container_exists; then
    return 0
  fi

  require_cleanup_container
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
    printf '  docker pull %s\n' "$BASE_IMAGE" >&2
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
    --ipc private \
    --cgroupns private \
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

check_lab() {
  require_docker
  require_owned_container
  CONTAINER_NAME="$CONTAINER_NAME" EXPECTED_LABEL="$CONTAINER_LABEL" \
    bash "$LAB_DIRECTORY/internal/verify-fixture.sh"
}

reset_lab() {
  require_docker
  remove_owned_container
  setup_lab
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
  printf 'Usage: bash lab.sh {setup|status|check|shell|reset|cleanup}\n' >&2
}

main() {
  local command="${1:-}"
  case "$command" in
    setup) setup_lab ;;
    status) show_status ;;
    check) check_lab ;;
    shell) open_shell ;;
    reset) reset_lab ;;
    cleanup) cleanup_lab ;;
    *) usage; return 2 ;;
  esac
}

main "$@"
