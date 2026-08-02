#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

readonly LESSON_ID='LES-0023'
readonly STATE_VERSION='1'
readonly BASE_IMAGE='busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662'
readonly CONTAINER_NAME="reliability-atlas-les0023-u${EUID}"
readonly LABEL_LESSON='reliability-atlas.lesson'
readonly LABEL_OWNER='reliability-atlas.owner-uid'
readonly LABEL_INSTANCE='reliability-atlas.instance'
readonly STATE_PARENT='/tmp'
readonly STATE_FILE="${STATE_PARENT}/reliability-atlas-LES-0023-${EUID}.state"
readonly CASE_FILE="${STATE_PARENT}/reliability-atlas-LES-0023-${EUID}.case"
readonly RECOVERY_FILE="${STATE_PARENT}/reliability-atlas-LES-0023-${EUID}.recovery"
readonly VERIFICATION_FILE="${STATE_PARENT}/reliability-atlas-LES-0023-${EUID}.verification"
readonly CANDIDATE_PREFIX="reliability-atlas-LES-0023-${EUID}.candidate."
readonly LAB_UID="$EUID"
# shellcheck disable=SC2016 # The literal is evaluated by the container shell, not this controller.
readonly WORKLOAD_SCRIPT='set -eu
trap '\''printf "event=signal signal=TERM pid=%s\n" "$$"; exit 0'\'' TERM
trap '\''printf "event=signal signal=INT pid=%s\n" "$$"; exit 0'\'' INT
printf "ready\n" > /run/ready
printf "event=start pid=%s uid=%s\n" "$$" "$(id -u)"
while :; do
  sleep 1 &
  wait "$!"
done'

DESCRIPTOR_CONTAINER_ID=''
DESCRIPTOR_INSTANCE=''
DESCRIPTOR_IMAGE_ID=''
PENDING_CANDIDATE=''
PENDING_CONTAINER_ID=''
PENDING_INSTANCE=''

die() {
  local message=${1:-unknown-error}
  local status=${2:-1}
  printf 'error=%s\n' "$message" >&2
  exit "$status"
}

path_present() {
  [[ -e $1 || -L $1 ]]
}

require_command() {
  command -v -- "$1" >/dev/null 2>&1 || die "missing-required-command-$1" 69
}

require_normal_user() {
  ((LAB_UID != 0)) || die 'root-is-refused-run-as-a-normal-user' 77
}

validate_local_environment() {
  local command_name tmp_owner tmp_mode
  require_normal_user
  [[ ${BASH_VERSINFO[0]} -ge 5 ]] || die 'bash-5-or-newer-required' 69
  for command_name in bash chmod cmp docker find grep id ln mktemp od readlink rm stat timeout tr; do
    require_command "$command_name"
  done
  [[ -d $STATE_PARENT && ! -L $STATE_PARENT ]] || die 'tmp-must-be-real-directory' 73
  tmp_owner=$(stat -c '%u' -- "$STATE_PARENT") || die 'cannot-read-tmp-owner' 73
  tmp_mode=$(stat -c '%a' -- "$STATE_PARENT") || die 'cannot-read-tmp-mode' 73
  [[ $tmp_owner == 0 ]] || die 'tmp-must-be-owned-by-root' 73
  [[ $tmp_mode == 1777 ]] || die "tmp-mode-must-be-1777-found-${tmp_mode}" 73
}

require_daemon() {
  timeout 20 docker version >/dev/null 2>&1 || die 'docker-daemon-unavailable-start-docker-desktop-and-enable-wsl-integration' 69
}

require_cached_image() {
  timeout 20 docker image inspect "$BASE_IMAGE" >/dev/null 2>&1 || die 'pinned-busybox-image-not-cached-offline-lab-will-not-pull' 69
}

container_exists() {
  timeout 20 docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1
}

artifact_orphan() {
  local path
  for path in "$STATE_FILE" "$CASE_FILE" "$RECOVERY_FILE" "$VERIFICATION_FILE"; do
    if path_present "$path"; then printf '%s\n' "$path"; return 0; fi
  done
  find -P "$STATE_PARENT" -mindepth 1 -maxdepth 1 -name "${CANDIDATE_PREFIX}*" -print -quit 2>/dev/null
}

require_clean_start() {
  local orphan
  orphan=$(artifact_orphan)
  [[ -z $orphan ]] || die 'unregistered-or-stale-local-artifact-found-refusing-to-guess' 73
  ! container_exists || die 'unregistered-container-name-already-exists-refusing-to-replace' 73
}

validate_regular_file() {
  local path=$1 expected_mode=$2 owner mode links
  [[ -f $path && ! -L $path ]] || die "expected-regular-file-${path##*/}" 73
  owner=$(stat -c '%u' -- "$path") || die "cannot-read-owner-${path##*/}" 73
  mode=$(stat -c '%a' -- "$path") || die "cannot-read-mode-${path##*/}" 73
  links=$(stat -c '%h' -- "$path") || die "cannot-read-links-${path##*/}" 73
  [[ $owner == "$LAB_UID" ]] || die "unexpected-owner-${path##*/}" 73
  [[ $mode == "$expected_mode" ]] || die "unexpected-mode-${path##*/}-${mode}" 73
  [[ $links == 1 ]] || die "unexpected-link-count-${path##*/}-${links}" 73
}

load_descriptor() {
  local -a lines=()
  validate_regular_file "$STATE_FILE" 600
  mapfile -t lines <"$STATE_FILE"
  ((${#lines[@]} == 8)) || die 'state-descriptor-field-count-invalid' 73
  [[ ${lines[0]} == "lesson=${LESSON_ID}" ]] || die 'state-descriptor-lesson-invalid' 73
  [[ ${lines[1]} == "version=${STATE_VERSION}" ]] || die 'state-descriptor-version-invalid' 73
  [[ ${lines[2]} == "uid=${LAB_UID}" ]] || die 'state-descriptor-uid-invalid' 73
  [[ ${lines[3]} == "container_name=${CONTAINER_NAME}" ]] || die 'state-descriptor-name-invalid' 73
  [[ ${lines[4]} =~ ^container_id=[0-9a-f]{64}$ ]] || die 'state-descriptor-container-id-invalid' 73
  [[ ${lines[5]} =~ ^instance=[0-9a-f]{24}$ ]] || die 'state-descriptor-instance-invalid' 73
  [[ ${lines[6]} == "image_ref=${BASE_IMAGE}" ]] || die 'state-descriptor-image-reference-invalid' 73
  [[ ${lines[7]} =~ ^image_id=sha256:[0-9a-f]{64}$ ]] || die 'state-descriptor-image-id-invalid' 73
  DESCRIPTOR_CONTAINER_ID=${lines[4]#container_id=}
  DESCRIPTOR_INSTANCE=${lines[5]#instance=}
  DESCRIPTOR_IMAGE_ID=${lines[7]#image_id=}
}

validate_optional_artifact() {
  local path=$1 kind=$2 first second
  if ! path_present "$path"; then return 0; fi
  validate_regular_file "$path" 600
  first=$(grep -E '^lesson=' "$path" || true)
  second=$(grep -E "^container_id=${DESCRIPTOR_CONTAINER_ID}$" "$path" || true)
  [[ $first == "lesson=${LESSON_ID}" && -n $second ]] || die "${kind}-artifact-content-invalid" 73
}

container_profile() {
  timeout 20 docker container inspect --format '{{.Id}}|{{.Name}}|{{.Config.Image}}|{{.Image}}|{{.Config.User}}|{{index .Config.Labels "reliability-atlas.lesson"}}|{{index .Config.Labels "reliability-atlas.owner-uid"}}|{{index .Config.Labels "reliability-atlas.instance"}}|{{.Path}}|{{.HostConfig.NetworkMode}}|{{.HostConfig.ReadonlyRootfs}}|{{.HostConfig.Privileged}}|{{json .HostConfig.CapDrop}}|{{if .HostConfig.CapAdd}}{{len .HostConfig.CapAdd}}{{else}}0{{end}}|{{json .HostConfig.SecurityOpt}}|{{.HostConfig.PidsLimit}}|{{.HostConfig.Memory}}|{{.HostConfig.MemorySwap}}|{{.HostConfig.NanoCpus}}|{{.HostConfig.RestartPolicy.Name}}|{{.HostConfig.AutoRemove}}|{{if .HostConfig.Binds}}{{len .HostConfig.Binds}}{{else}}0{{end}}|{{if .Mounts}}{{len .Mounts}}{{else}}0{{end}}|{{if .HostConfig.VolumesFrom}}{{len .HostConfig.VolumesFrom}}{{else}}0{{end}}|{{if .HostConfig.Devices}}{{len .HostConfig.Devices}}{{else}}0{{end}}|{{if .HostConfig.DeviceRequests}}{{len .HostConfig.DeviceRequests}}{{else}}0{{end}}|{{.HostConfig.PidMode}}|{{.HostConfig.IpcMode}}|{{.HostConfig.CgroupnsMode}}|{{if .HostConfig.Tmpfs}}{{len .HostConfig.Tmpfs}}{{else}}0{{end}}|{{index .HostConfig.Tmpfs "/run"}}|{{index .HostConfig.Tmpfs "/work"}}|{{if .HostConfig.PortBindings}}{{len .HostConfig.PortBindings}}{{else}}0{{end}}|{{.HostConfig.PublishAllPorts}}|{{json .Config.Healthcheck.Test}}' "$CONTAINER_NAME"
}

csv_options_match() {
  local actual=$1
  shift
  local -a actual_options=()
  local required option found
  IFS=',' read -r -a actual_options <<<"$actual"
  ((${#actual_options[@]} == $#)) || return 1
  for required in "$@"; do
    found=false
    for option in "${actual_options[@]}"; do
      if [[ $option == "$required" ]]; then found=true; break; fi
    done
    [[ $found == true ]] || return 1
  done
}

validate_registered_container() {
  local profile id name image_ref image_id user lesson_label owner_label instance_label path
  local network rootfs_readonly privileged cap_drop cap_add_count security pids memory memory_swap cpus restart auto_remove
  local bind_count mount_count volumes_from device_count device_requests pid_mode ipc_mode cgroupns_mode tmpfs_count
  local run_options work_options port_count publish_all health_test cached_image_id
  local -a expected_run expected_work

  load_descriptor
  validate_optional_artifact "$CASE_FILE" case
  validate_optional_artifact "$RECOVERY_FILE" recovery
  validate_optional_artifact "$VERIFICATION_FILE" verification
  container_exists || die 'registered-container-is-absent' 73
  profile=$(container_profile) || die 'cannot-inspect-registered-container' 73
  IFS='|' read -r id name image_ref image_id user lesson_label owner_label instance_label path network rootfs_readonly privileged \
    cap_drop cap_add_count security pids memory memory_swap cpus restart auto_remove bind_count mount_count volumes_from \
    device_count device_requests pid_mode ipc_mode cgroupns_mode tmpfs_count run_options work_options port_count publish_all health_test <<<"$profile"

  [[ $id == "$DESCRIPTOR_CONTAINER_ID" && $name == "/${CONTAINER_NAME}" ]] || die 'container-identity-does-not-match-descriptor' 73
  [[ $image_ref == "$BASE_IMAGE" && $image_id == "$DESCRIPTOR_IMAGE_ID" ]] || die 'container-image-does-not-match-descriptor' 73
  cached_image_id=$(timeout 20 docker image inspect --format '{{.Id}}' "$BASE_IMAGE") || die 'cached-image-disappeared' 73
  [[ $cached_image_id == "$image_id" ]] || die 'container-image-id-no-longer-matches-cached-digest' 73
  [[ $user == '65534:65534' ]] || die 'container-user-envelope-invalid' 73
  [[ $lesson_label == "$LESSON_ID" && $owner_label == "$LAB_UID" && $instance_label == "$DESCRIPTOR_INSTANCE" ]] || die 'container-label-envelope-invalid' 73
  [[ $path == sh && $network == none && $rootfs_readonly == true && $privileged == false ]] || die 'container-runtime-envelope-invalid' 73
  [[ $cap_drop == '["ALL"]' && $cap_add_count == 0 ]] || die 'container-capability-envelope-invalid' 73
  case $security in '["no-new-privileges"]'|'["no-new-privileges=true"]'|'["no-new-privileges:true"]') ;; *) die 'container-security-option-envelope-invalid' 73 ;; esac
  [[ $pids == 64 && $memory == 67108864 && $memory_swap == 67108864 && $cpus == 250000000 ]] || die 'container-resource-envelope-invalid' 73
  [[ $restart == no && $auto_remove == false ]] || die 'container-lifecycle-envelope-invalid' 73
  [[ $bind_count == 0 && $mount_count == 0 && $volumes_from == 0 && $device_count == 0 && $device_requests == 0 ]] || die 'container-host-access-envelope-invalid' 73
  [[ -z $pid_mode && $ipc_mode == private && ( $cgroupns_mode == private || -z $cgroupns_mode ) ]] || die 'container-namespace-envelope-invalid' 73
  [[ $tmpfs_count == 2 && $port_count == 0 && $publish_all == false ]] || die 'container-mount-or-port-envelope-invalid' 73
  IFS=',' read -r -a expected_run <<<"rw,nosuid,nodev,noexec,size=1m,uid=65534,gid=65534,mode=0755"
  IFS=',' read -r -a expected_work <<<"rw,nosuid,nodev,noexec,size=4m,uid=65534,gid=65534,mode=0755"
  csv_options_match "$run_options" "${expected_run[@]}" || die 'run-tmpfs-envelope-invalid' 73
  csv_options_match "$work_options" "${expected_work[@]}" || die 'work-tmpfs-envelope-invalid' 73
  [[ $health_test == '["CMD-SHELL","test -f /run/ready"]' ]] || die 'container-healthcheck-envelope-invalid' 73
}

write_artifact() {
  local target=$1 content=$2 candidate
  ! path_present "$target" || die "artifact-already-exists-${target##*/}" 73
  candidate=$(mktemp --tmpdir="$STATE_PARENT" "${CANDIDATE_PREFIX}XXXXXXXX") || die 'cannot-create-artifact-candidate' 73
  PENDING_CANDIDATE=$candidate
  printf '%s\n' "$content" >"$candidate"
  chmod 600 -- "$candidate"
  validate_regular_file "$candidate" 600
  ln -- "$candidate" "$target" || die "cannot-register-artifact-${target##*/}" 73
  rm -- "$candidate"
  PENDING_CANDIDATE=''
  validate_regular_file "$target" 600
}

expected_descriptor() {
  local container_id=$1 instance=$2 image_id=$3
  printf 'lesson=%s\nversion=%s\nuid=%s\ncontainer_name=%s\ncontainer_id=%s\ninstance=%s\nimage_ref=%s\nimage_id=%s\n' \
    "$LESSON_ID" "$STATE_VERSION" "$LAB_UID" "$CONTAINER_NAME" "$container_id" "$instance" "$BASE_IMAGE" "$image_id"
}

pending_cleanup() {
  local original_status=$? actual_id actual_instance
  if [[ -n $PENDING_CANDIDATE && -f $PENDING_CANDIDATE && ! -L $PENDING_CANDIDATE ]]; then
    if [[ $(stat -c '%u:%h' -- "$PENDING_CANDIDATE" 2>/dev/null || true) == "$LAB_UID:1" ]]; then rm -- "$PENDING_CANDIDATE" 2>/dev/null || true; fi
  fi
  if [[ -n $PENDING_CONTAINER_ID ]] && container_exists; then
    actual_id=$(timeout 10 docker container inspect --format '{{.Id}}' "$CONTAINER_NAME" 2>/dev/null || true)
    actual_instance=$(timeout 10 docker container inspect --format '{{index .Config.Labels "reliability-atlas.instance"}}' "$CONTAINER_NAME" 2>/dev/null || true)
    if [[ $actual_id == "$PENDING_CONTAINER_ID" && $actual_instance == "$PENDING_INSTANCE" ]]; then
      timeout 20 docker container rm --force "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
  fi
  return "$original_status"
}

trap pending_cleanup EXIT
trap 'exit 130' INT TERM

wait_for_health() {
  local expected=$1 status
  for _ in {1..20}; do
    status=$(timeout 10 docker container inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$CONTAINER_NAME") || return 1
    if [[ $status == "$expected" ]]; then return 0; fi
    sleep 1
  done
  return 1
}

load_case() {
  local line
  validate_regular_file "$CASE_FILE" 600
  line=$(grep -E '^case=(guided|independent)$' "$CASE_FILE" || true)
  [[ $line == case=guided || $line == case=independent ]] || die 'case-artifact-invalid' 73
  grep -Fqx "container_id=${DESCRIPTOR_CONTAINER_ID}" "$CASE_FILE" || die 'case-container-id-invalid' 73
  printf '%s' "${line#case=}"
}

require_running() {
  local state
  state=$(timeout 10 docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME") || die 'cannot-read-container-state' 73
  [[ $state == running ]] || die "container-not-running-state-${state}" 73
}

command_check() {
  local orphan
  validate_local_environment
  require_daemon
  require_cached_image
  if path_present "$STATE_FILE"; then
    validate_registered_container
    printf 'lesson=%s\nruntime=ready\nstate=registered\ncontainer=%s\nimage_cached=true\nnetwork=none\n' "$LESSON_ID" "$CONTAINER_NAME"
    return 0
  fi
  orphan=$(artifact_orphan)
  [[ -z $orphan ]] || die 'unregistered-or-stale-local-artifact-found-refusing-to-guess' 73
  ! container_exists || die 'unregistered-container-name-already-exists-refusing-to-replace' 73
  printf 'lesson=%s\nruntime=ready\nstate=absent\nimage_cached=true\nnetwork=none\n' "$LESSON_ID"
}

command_setup() {
  local instance image_id container_id
  validate_local_environment
  require_daemon
  require_cached_image
  if path_present "$STATE_FILE"; then
    validate_registered_container
    printf 'setup=already-present\ncontainer=%s\ncontainer_id=%s\nnetwork=none\n' "$CONTAINER_NAME" "$DESCRIPTOR_CONTAINER_ID"
    return 0
  fi
  require_clean_start
  instance=$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')
  [[ $instance =~ ^[0-9a-f]{24}$ ]] || die 'cannot-generate-instance-token' 70
  image_id=$(timeout 20 docker image inspect --format '{{.Id}}' "$BASE_IMAGE") || die 'cannot-read-cached-image-id' 69
  container_id=$(timeout 30 docker run --detach --pull=never \
    --name "$CONTAINER_NAME" \
    --label "${LABEL_LESSON}=${LESSON_ID}" \
    --label "${LABEL_OWNER}=${LAB_UID}" \
    --label "${LABEL_INSTANCE}=${instance}" \
    --user 65534:65534 \
    --network none \
    --read-only \
    --cap-drop ALL \
    --security-opt no-new-privileges=true \
    --pids-limit 64 \
    --memory 64m \
    --memory-swap 64m \
    --cpus 0.25 \
    --ipc private \
    --cgroupns private \
    --restart no \
    --stop-timeout 3 \
    --tmpfs /run:rw,nosuid,nodev,noexec,size=1m,uid=65534,gid=65534,mode=0755 \
    --tmpfs /work:rw,nosuid,nodev,noexec,size=4m,uid=65534,gid=65534,mode=0755 \
    --health-cmd 'test -f /run/ready' \
    --health-interval 1s \
    --health-timeout 1s \
    --health-retries 3 \
    "$BASE_IMAGE" sh -c "$WORKLOAD_SCRIPT") || die 'docker-run-failed-without-network-pull' 70
  [[ $container_id =~ ^[0-9a-f]{64}$ ]] || die 'docker-returned-invalid-container-id' 70
  PENDING_CONTAINER_ID=$container_id
  PENDING_INSTANCE=$instance
  write_artifact "$STATE_FILE" "$(expected_descriptor "$container_id" "$instance" "$image_id")"
  PENDING_CONTAINER_ID=''
  PENDING_INSTANCE=''
  validate_registered_container
  require_running
  wait_for_health healthy || die 'container-did-not-become-healthy' 70
  printf 'setup=complete\ncontainer=%s\ncontainer_id=%s\nimage_ref=%s\nnetwork=none\nnext_command=bash lab.sh observe image\n' \
    "$CONTAINER_NAME" "$DESCRIPTOR_CONTAINER_ID" "$BASE_IMAGE"
}

command_status() {
  local state health exit_code oom case_value='none' recovery='pending' verification='pending'
  validate_local_environment
  require_daemon
  require_cached_image
  validate_registered_container
  state=$(timeout 10 docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME")
  health=$(timeout 10 docker container inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$CONTAINER_NAME")
  exit_code=$(timeout 10 docker container inspect --format '{{.State.ExitCode}}' "$CONTAINER_NAME")
  oom=$(timeout 10 docker container inspect --format '{{.State.OOMKilled}}' "$CONTAINER_NAME")
  if path_present "$CASE_FILE"; then case_value=$(load_case); fi
  path_present "$RECOVERY_FILE" && recovery='complete'
  path_present "$VERIFICATION_FILE" && verification='complete'
  printf 'state=%s\nhealth=%s\nexit_code=%s\noom_killed=%s\ncase=%s\nrecovery=%s\nverification=%s\ncontainer=%s\n' \
    "$state" "$health" "$exit_code" "$oom" "$case_value" "$recovery" "$verification" "$CONTAINER_NAME"
}

command_observe() {
  local view=$1 state
  case $view in image|runtime|filesystem|limits|process|network|health|logs) ;; *) die 'view-not-allowlisted' 64 ;; esac
  validate_local_environment
  require_daemon
  require_cached_image
  validate_registered_container
  printf 'record=observation\nview=%s\ncontainer=%s\n' "$view" "$CONTAINER_NAME"
  case $view in
    image)
      timeout 20 docker image inspect --format 'image_id={{.Id}}\narchitecture={{.Architecture}}\nos={{.Os}}\nrootfs_type={{.RootFS.Type}}\nlayer_count={{len .RootFS.Layers}}\nconfig_user={{if index .Config "User"}}{{index .Config "User"}}{{else}}unspecified{{end}}\nconfig_entrypoint={{if index .Config "Entrypoint"}}{{json (index .Config "Entrypoint")}}{{else}}null{{end}}\nconfig_cmd={{if index .Config "Cmd"}}{{json (index .Config "Cmd")}}{{else}}null{{end}}' "$BASE_IMAGE"
      ;;
    runtime)
      timeout 20 docker container inspect --format 'status={{.State.Status}}\nrunning={{.State.Running}}\nexit_code={{.State.ExitCode}}\noom_killed={{.State.OOMKilled}}\nrestart_count={{.RestartCount}}\npath={{.Path}}\nargs={{json .Args}}\nreadonly_rootfs={{.HostConfig.ReadonlyRootfs}}\nprivileged={{.HostConfig.Privileged}}' "$CONTAINER_NAME"
      ;;
    filesystem)
      timeout 20 docker container inspect --format 'graph_driver={{.GraphDriver.Name}}\nreadonly_rootfs={{.HostConfig.ReadonlyRootfs}}\ntmpfs_run={{index .HostConfig.Tmpfs "/run"}}\ntmpfs_work={{index .HostConfig.Tmpfs "/work"}}\nbind_count={{if .HostConfig.Binds}}{{len .HostConfig.Binds}}{{else}}0{{end}}\nmount_count={{if .Mounts}}{{len .Mounts}}{{else}}0{{end}}' "$CONTAINER_NAME"
      printf 'rootfs_changes_begin\n'
      timeout 20 docker diff "$CONTAINER_NAME" || true
      printf 'rootfs_changes_end\n'
      ;;
    limits)
      timeout 20 docker container inspect --format 'memory_bytes={{.HostConfig.Memory}}\nmemory_swap_bytes={{.HostConfig.MemorySwap}}\nnano_cpus={{.HostConfig.NanoCpus}}\npids_limit={{.HostConfig.PidsLimit}}\ncap_drop={{json .HostConfig.CapDrop}}\nsecurity_opt={{json .HostConfig.SecurityOpt}}' "$CONTAINER_NAME"
      state=$(timeout 10 docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME")
      # shellcheck disable=SC2016 # Expanded only by the container shell.
      if [[ $state == running ]]; then timeout 20 docker container exec "$CONTAINER_NAME" sh -c 'for f in memory.max cpu.max pids.max; do if [ -r "/sys/fs/cgroup/$f" ]; then printf "cgroup_%s=" "$f"; cat "/sys/fs/cgroup/$f"; fi; done'; fi
      ;;
    process)
      state=$(timeout 10 docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME")
      printf 'container_state=%s\n' "$state"
      if [[ $state == running ]]; then timeout 20 docker top "$CONTAINER_NAME" -eo pid,ppid,user,comm,args; else printf 'process_table=unavailable-container-not-running\n'; fi
      ;;
    network)
      timeout 20 docker container inspect --format 'network_mode={{.HostConfig.NetworkMode}}\npublished_port_count={{len .HostConfig.PortBindings}}\npublish_all_ports={{.HostConfig.PublishAllPorts}}\nnetwork_settings={{json .NetworkSettings.Networks}}' "$CONTAINER_NAME"
      state=$(timeout 10 docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME")
      if [[ $state == running ]]; then timeout 20 docker container exec "$CONTAINER_NAME" cat /proc/net/dev; fi
      ;;
    health)
      timeout 20 docker container inspect --format 'status={{.State.Status}}\nhealth={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}\nhealth_log_entries={{if .State.Health}}{{len .State.Health.Log}}{{else}}0{{end}}' "$CONTAINER_NAME"
      ;;
    logs)
      printf 'logs_begin\n'
      timeout 20 docker container logs --tail 20 "$CONTAINER_NAME" 2>&1
      printf 'logs_end\n'
      ;;
  esac
}

command_inject() {
  local case_name=$1 state content
  [[ $case_name == guided || $case_name == independent ]] || die 'case-must-be-guided-or-independent' 64
  validate_local_environment
  require_daemon
  require_cached_image
  validate_registered_container
  ! path_present "$CASE_FILE" || die 'case-already-active' 73
  ! path_present "$RECOVERY_FILE" || die 'recovery-already-present' 73
  require_running
  content=$(printf 'lesson=%s\ncontainer_id=%s\ncase=%s\n' "$LESSON_ID" "$DESCRIPTOR_CONTAINER_ID" "$case_name")
  write_artifact "$CASE_FILE" "$content"
  if [[ $case_name == guided ]]; then
    timeout 20 docker container exec --user 65534:65534 "$CONTAINER_NAME" rm -- /run/ready || die 'cannot-inject-guided-health-failure' 70
    wait_for_health unhealthy || die 'guided-container-did-not-become-unhealthy' 70
    printf 'injection=complete\ncase=guided\nvisible_signal=health-unhealthy\nanswer_key=not-provided\nnext_command=bash lab.sh observe health\n'
  else
    timeout 20 docker stop --time 3 "$CONTAINER_NAME" >/dev/null || die 'cannot-inject-independent-stop' 70
    state=$(timeout 10 docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME")
    [[ $state == exited ]] || die 'independent-container-did-not-stop' 70
    printf 'injection=complete\ncase=independent\nraw_scenario_available=true\nanswer_key=not-provided\nnext_command=bash lab.sh scenario\n'
  fi
}

command_scenario() {
  local case_name output forbidden
  validate_local_environment
  require_daemon
  require_cached_image
  validate_registered_container
  case_name=$(load_case)
  [[ $case_name == independent ]] || die 'scenario-only-available-for-independent-case' 73
  ! path_present "$RECOVERY_FILE" || die 'scenario-unavailable-after-recovery' 73
  output=$(printf 'record=scenario_input\ncase=independent\nworkload=signal-aware-worker\nrequested_action=maintenance-stop\nstop_timeout_seconds=3\nconfigured_user=65534:65534\nroot_filesystem=read-only\nnetwork_mode=none\nwork_contract=finish-or-record-inflight-work-before-exit\n')
  for forbidden in exit_code stopped signal_received outcome diagnosis recovery answer_key process_state health_state; do
    if grep -Fiq -- "$forbidden" <<<"$output"; then die "scenario-exposed-derived-field-${forbidden}" 70; fi
  done
  printf '%s\n' "$output"
}

command_recover() {
  local case_name content
  validate_local_environment
  require_daemon
  require_cached_image
  validate_registered_container
  case_name=$(load_case)
  ! path_present "$RECOVERY_FILE" || die 'recovery-already-recorded' 73
  if [[ $case_name == guided ]]; then
    require_running
    timeout 20 docker container exec --user 65534:65534 "$CONTAINER_NAME" sh -c 'printf "ready\n" > /run/ready' || die 'cannot-restore-health-marker' 70
  else
    timeout 20 docker start "$CONTAINER_NAME" >/dev/null || die 'cannot-restart-owned-container' 70
  fi
  wait_for_health healthy || die 'container-did-not-return-healthy' 70
  content=$(printf 'lesson=%s\ncontainer_id=%s\ncase=%s\nrecovery=bounded\n' "$LESSON_ID" "$DESCRIPTOR_CONTAINER_ID" "$case_name")
  write_artifact "$RECOVERY_FILE" "$content"
  printf 'record=recovery\ncase=%s\ncontainer=%s\nstate=running\nhealth=healthy\nnext_command=bash lab.sh verify-operation\n' "$case_name" "$CONTAINER_NAME"
}

command_verify_operation() {
  local case_name state health uid_value rootfs_write='unexpectedly-succeeded' work_probe logs content
  validate_local_environment
  require_daemon
  require_cached_image
  validate_registered_container
  case_name=$(load_case)
  validate_regular_file "$RECOVERY_FILE" 600
  ! path_present "$VERIFICATION_FILE" || die 'verification-already-recorded' 73
  state=$(timeout 10 docker container inspect --format '{{.State.Status}}' "$CONTAINER_NAME")
  health=$(timeout 10 docker container inspect --format '{{.State.Health.Status}}' "$CONTAINER_NAME")
  [[ $state == running && $health == healthy ]] || die 'verification-requires-running-healthy-container' 70
  uid_value=$(timeout 20 docker container exec "$CONTAINER_NAME" id -u)
  [[ $uid_value == 65534 ]] || die 'container-effective-uid-verification-failed' 70
  if ! timeout 20 docker container exec "$CONTAINER_NAME" sh -c ': > /rootfs-write-probe' >/dev/null 2>&1; then rootfs_write='refused'; fi
  [[ $rootfs_write == refused ]] || die 'read-only-rootfs-verification-failed' 70
  work_probe="probe-${DESCRIPTOR_INSTANCE}"
  # shellcheck disable=SC2016 # Positional parameters expand only in the container shell.
  timeout 20 docker container exec "$CONTAINER_NAME" sh -c 'printf "%s\n" "$1" > /work/probe && test "$(cat /work/probe)" = "$1" && rm /work/probe' sh "$work_probe" || die 'writable-tmpfs-verification-failed' 70
  logs=$(timeout 20 docker container logs "$CONTAINER_NAME" 2>&1)
  grep -Fq 'event=start pid=1 uid=65534' <<<"$logs" || die 'pid1-start-log-verification-failed' 70
  if [[ $case_name == independent ]]; then grep -Fq 'event=signal signal=TERM pid=1' <<<"$logs" || die 'pid1-term-log-verification-failed' 70; fi
  content=$(printf 'lesson=%s\ncontainer_id=%s\ncase=%s\nverification=complete\n' "$LESSON_ID" "$DESCRIPTOR_CONTAINER_ID" "$case_name")
  write_artifact "$VERIFICATION_FILE" "$content"
  printf 'record=verification\ncase=%s\nstate=running\nhealth=healthy\ncontainer_uid=65534\npid1_signal_contract=%s\nread_only_rootfs=verified\nwritable_tmpfs=verified\nnetwork=none\ncleanup_required=true\n' \
    "$case_name" "$(if [[ $case_name == independent ]]; then printf verified; else printf not-exercised-guided; fi)"
}

remove_local_artifact() {
  local path=$1
  if path_present "$path"; then validate_regular_file "$path" 600; rm -- "$path"; fi
}

command_cleanup() {
  local cleanup_mode='complete'
  validate_local_environment
  require_daemon
  require_cached_image
  if ! path_present "$STATE_FILE"; then
    local orphan
    orphan=$(artifact_orphan)
    [[ -z $orphan ]] || die 'local-artifact-exists-without-state-refusing-cleanup' 73
    ! container_exists || die 'container-name-exists-without-state-refusing-cleanup' 73
    printf 'cleanup=already-clean\ncontainer_absent=true\nlocal_state_absent=true\ncleanup_proven=true\n'
    return 0
  fi
  load_descriptor
  validate_optional_artifact "$CASE_FILE" case
  validate_optional_artifact "$RECOVERY_FILE" recovery
  validate_optional_artifact "$VERIFICATION_FILE" verification
  if container_exists; then
    validate_registered_container
    timeout 30 docker container rm --force "$CONTAINER_NAME" >/dev/null || die 'cannot-remove-exact-owned-container' 70
  else
    cleanup_mode='resumed-container-already-absent'
  fi
  ! container_exists || die 'container-still-present-after-removal' 70
  remove_local_artifact "$VERIFICATION_FILE"
  remove_local_artifact "$RECOVERY_FILE"
  remove_local_artifact "$CASE_FILE"
  validate_regular_file "$STATE_FILE" 600
  rm -- "$STATE_FILE"
  [[ -z $(artifact_orphan) ]] || die 'local-artifact-remains-after-cleanup' 73
  printf 'cleanup=%s\ncontainer_absent=true\nlocal_state_absent=true\ncleanup_proven=true\n' "$cleanup_mode"
}

usage() {
  cat >&2 <<'USAGE'
usage:
  bash lab.sh check
  bash lab.sh setup
  bash lab.sh status
  bash lab.sh observe image|runtime|filesystem|limits|process|network|health|logs
  bash lab.sh inject guided|independent
  bash lab.sh scenario
  bash lab.sh recover
  bash lab.sh verify-operation
  bash lab.sh cleanup
USAGE
  return 64
}

main() {
  local command=${1:-}
  case $command in
    check|setup|status|scenario|recover|verify-operation|cleanup)
      (($# == 1)) || { usage; exit 64; }
      "command_${command//-/_}"
      ;;
    observe|inject)
      (($# == 2)) || { usage; exit 64; }
      "command_${command}" "$2"
      ;;
    *) usage; exit 64 ;;
  esac
}

main "$@"
