#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
FIXTURE="$DIR/fixtures/cases.json"
MODEL="$DIR/model.py"
STATE="/tmp/reliability-atlas-les0080-bare-metal-$(id -u)"
SENTINEL="$STATE/.les0080"
die(){ printf 'lab=fail reason=%s\n' "$1" >&2; exit 1; }

guard(){
  [[ "$(id -u)" -ne 0 ]] || die root-refused
  command -v python3 >/dev/null 2>&1 || die python3-missing
  [[ -z "${REDFISH_URL:-}${REDFISH_ENDPOINT:-}${REDFISH_PASSWORD:-}${BMC_ADDRESS:-}${BMC_HOST:-}${BMC_USERNAME:-}${BMC_PASSWORD:-}${IPMI_HOST:-}${IPMI_PASSWORD:-}${IRONIC_URL:-}${IRONIC_ENDPOINT:-}${IRONIC_API_VERSION:-}${MAAS_URL:-}${MAAS_API_KEY:-}${PXE_INTERFACE:-}${PROVISIONING_INTERFACE:-}${TFTP_ROOT:-}${HTTP_BOOT_ROOT:-}${OS_AUTH_URL:-}${OS_TOKEN:-}${OS_PASSWORD:-}${OS_CLOUD:-}${KUBECONFIG:-}${DOCKER_HOST:-}${LIBVIRT_DEFAULT_URI:-}${VIRSH_DEFAULT_CONNECT_URI:-}${AWS_PROFILE:-}${AZURE_CLIENT_SECRET:-}${GOOGLE_APPLICATION_CREDENTIALS:-}" ]] || die credential-or-runtime-authority
  local device
  for device in /dev/ipmi0 /dev/ipmi/0 /dev/ipmidev/0; do
    [[ ! -e "$device" ]] || die hardware-control-device-detected
  done
  [[ ! -L "$STATE" ]] || die state-symlink
  if [[ -e "$STATE" ]]; then
    [[ -d "$STATE" && -O "$STATE" && -f "$SENTINEL" && ! -L "$SENTINEL" ]] || die state-ownership
    [[ "$(<"$SENTINEL")" == "LES-0080:$(id -u)" ]] || die sentinel
  fi
}

inventory(){
  local item relative
  while IFS= read -r -d '' item; do
    relative="${item#"$STATE"/}"
    case "$relative" in .les0080|cases.json) ;; *) die "unknown-artifact:$relative" ;; esac
    [[ ! -L "$item" ]] || die "artifact-symlink:$relative"
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}

present(){ command -v "$1" >/dev/null 2>&1 && printf yes || printf no; }

inventory_tools(){
  guard
  local environment=unknown
  if command -v systemd-detect-virt >/dev/null 2>&1; then
    environment="$(systemd-detect-virt 2>/dev/null || printf none)"
  fi
  printf 'inventory=observed architecture=%s environment=%s curl=%s ipmitool=%s redfishtool=%s baremetal=%s openstack=%s maas=%s ip=%s ethtool=%s lspci=%s dmidecode=%s smartctl=%s nvme=%s sensors=%s ras-mc-ctl=%s fwupdmgr=%s python3=%s hardware_runtime_calls=none\n' \
    "$(uname -m)" "$environment" "$(present curl)" "$(present ipmitool)" "$(present redfishtool)" "$(present baremetal)" "$(present openstack)" "$(present maas)" "$(present ip)" "$(present ethtool)" "$(present lspci)" "$(present dmidecode)" "$(present smartctl)" "$(present nvme)" "$(present sensors)" "$(present ras-mc-ctl)" "$(present fwupdmgr)" "$(present python3)"
}

doctor(){
  guard
  [[ -r "$FIXTURE" && -r "$MODEL" ]] || die source
  python3 "$MODEL" validate "$FIXTURE"
  printf 'doctor=pass network=none user=%s hardware_runtime_calls=none\n' "$(id -u)"
}

setup(){
  guard
  [[ ! -e "$STATE" ]] || die state-exists
  (
    umask 077
    mkdir -- "$STATE"
    printf 'LES-0080:%s\n' "$(id -u)" >"$SENTINEL"
    cp -- "$FIXTURE" "$STATE/cases.json"
  )
  guard
  inventory
  python3 "$MODEL" validate "$STATE/cases.json"
  printf 'setup=pass state=%s\n' "$STATE"
}

status(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  local count
  count="$(python3 "$MODEL" list "$STATE/cases.json" | wc -l | tr -d ' ')"
  printf 'status=ready cases=%s state=%s hardware_runtime_calls=none\n' "$count" "$STATE"
}

list_cases(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  python3 "$MODEL" list "$STATE/cases.json"
}

show_case(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  python3 "$MODEL" show "$STATE/cases.json" "$1"
}

evaluate(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  python3 "$MODEL" evaluate "$STATE/cases.json" "$1"
}

evaluate_all(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  python3 "$MODEL" evaluate-all "$STATE/cases.json"
}

inject_unknown(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  printf 'do-not-delete\n' >"$STATE/unknown"
  printf 'inject=pass artifact=unknown\n'
}

clear_unknown(){
  guard
  [[ -f "$STATE/unknown" && ! -L "$STATE/unknown" ]] || die unknown-missing
  rm -- "$STATE/unknown"
  inventory
  printf 'clear=pass artifact=unknown\n'
}

cleanup(){
  guard
  if [[ ! -d "$STATE" ]]; then
    printf 'cleanup=pass absent=true\n'
    return
  fi
  inventory
  rm -- "$STATE/cases.json" "$SENTINEL"
  rmdir -- "$STATE"
  [[ ! -e "$STATE" && ! -L "$STATE" ]] || die cleanup
  printf 'cleanup=pass absent=true\n'
}

case "${1:-help}" in
  doctor) [[ $# -eq 1 ]] || die arguments; doctor ;;
  inventory-tools) [[ $# -eq 1 ]] || die arguments; inventory_tools ;;
  setup) [[ $# -eq 1 ]] || die arguments; setup ;;
  status) [[ $# -eq 1 ]] || die arguments; status ;;
  list) [[ $# -eq 1 ]] || die arguments; list_cases ;;
  show) [[ $# -eq 2 ]] || die arguments; show_case "$2" ;;
  evaluate) [[ $# -eq 2 ]] || die arguments; evaluate "$2" ;;
  evaluate-all) [[ $# -eq 1 ]] || die arguments; evaluate_all ;;
  inject-unknown) [[ $# -eq 1 ]] || die arguments; inject_unknown ;;
  clear-unknown) [[ $# -eq 1 ]] || die arguments; clear_unknown ;;
  cleanup) [[ $# -eq 1 ]] || die arguments; cleanup ;;
  help|-h|--help) printf '%s\n' 'Usage: bash lab.sh doctor|inventory-tools|setup|status|list|show CASE|evaluate CASE|evaluate-all|cleanup' ;;
  *) die "unknown-command:${1:-}" ;;
esac
