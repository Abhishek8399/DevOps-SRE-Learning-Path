#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
FIXTURE="$DIR/fixtures/cases.json"
MODEL="$DIR/model.py"
STATE="/tmp/reliability-atlas-les0076-virtualization-$(id -u)"
SENTINEL="$STATE/.les0076"
die(){ printf 'lab=fail reason=%s\n' "$1" >&2; exit 1; }

guard(){
  [[ "$(id -u)" -ne 0 ]] || die root-refused
  command -v python3 >/dev/null 2>&1 || die python3-missing
  [[ -z "${AWS_PROFILE:-}${AWS_ACCESS_KEY_ID:-}${AZURE_CLIENT_SECRET:-}${GOOGLE_APPLICATION_CREDENTIALS:-}${KUBECONFIG:-}${DOCKER_HOST:-}${LIBVIRT_DEFAULT_URI:-}${VIRSH_DEFAULT_CONNECT_URI:-}" ]] || die credential-or-external-endpoint
  [[ ! -L "$STATE" ]] || die state-symlink
  if [[ -e "$STATE" ]]; then
    [[ -d "$STATE" && -O "$STATE" && -f "$SENTINEL" && ! -L "$SENTINEL" ]] || die state-ownership
    [[ "$(<"$SENTINEL")" == "LES-0076:$(id -u)" ]] || die sentinel
  fi
}

inventory(){
  local item relative
  while IFS= read -r -d '' item; do
    relative="${item#"$STATE"/}"
    case "$relative" in .les0076|cases.json) ;; *) die "unknown-artifact:$relative" ;; esac
    [[ ! -L "$item" ]] || die "artifact-symlink:$relative"
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}

present(){ command -v "$1" >/dev/null 2>&1 && printf yes || printf no; }

capability(){
  guard
  local architecture environment cpu_virtualization kvm_device
  architecture="$(uname -m)"
  environment=unknown
  if command -v systemd-detect-virt >/dev/null 2>&1; then
    environment="$(systemd-detect-virt 2>/dev/null || printf none)"
  fi
  cpu_virtualization=absent
  if awk '/^flags|^Features/{for(i=1;i<=NF;i++)if($i=="vmx"||$i=="svm"){found=1}}END{exit !found}' /proc/cpuinfo 2>/dev/null; then
    cpu_virtualization=present
  fi
  if [[ ! -e /dev/kvm ]]; then
    kvm_device=absent
  elif [[ -r /dev/kvm && -w /dev/kvm ]]; then
    kvm_device=accessible
  else
    kvm_device=inaccessible
  fi
  printf 'capability=observed architecture=%s environment=%s cpu_virtualization=%s kvm_device=%s qemu=%s virsh=%s host_validate=%s qemu_img=%s cloud_init=%s\n' \
    "$architecture" "$environment" "$cpu_virtualization" "$kvm_device" \
    "$(present qemu-system-x86_64)" "$(present virsh)" "$(present virt-host-validate)" \
    "$(present qemu-img)" "$(present cloud-init)"
}

doctor(){
  guard
  [[ -r "$FIXTURE" && -r "$MODEL" ]] || die source
  python3 "$MODEL" validate "$FIXTURE"
  printf 'doctor=pass network=none user=%s vm_actions=none\n' "$(id -u)"
}

setup(){
  guard
  [[ ! -e "$STATE" ]] || die state-exists
  (umask 077; mkdir -- "$STATE"; printf 'LES-0076:%s\n' "$(id -u)" >"$SENTINEL"; cp -- "$FIXTURE" "$STATE/cases.json")
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
  printf 'status=ready cases=%s state=%s\n' "$count" "$STATE"
}

list_cases(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; python3 "$MODEL" list "$STATE/cases.json"; }
show_case(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; python3 "$MODEL" show "$STATE/cases.json" "$1"; }
evaluate(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; python3 "$MODEL" evaluate "$STATE/cases.json" "$1"; }
evaluate_all(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; python3 "$MODEL" evaluate-all "$STATE/cases.json"; }
inject_unknown(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; printf 'do-not-delete\n' >"$STATE/unknown"; printf 'inject=pass artifact=unknown\n'; }
clear_unknown(){ guard; [[ -f "$STATE/unknown" && ! -L "$STATE/unknown" ]] || die unknown-missing; rm -- "$STATE/unknown"; inventory; printf 'clear=pass artifact=unknown\n'; }

cleanup(){
  guard
  [[ -d "$STATE" ]] || { printf 'cleanup=pass absent=true\n'; return; }
  inventory
  rm -- "$STATE/cases.json" "$SENTINEL"
  rmdir -- "$STATE"
  [[ ! -e "$STATE" && ! -L "$STATE" ]] || die cleanup
  printf 'cleanup=pass absent=true\n'
}

help_text(){
  cat <<'EOF'
Usage: bash lab.sh doctor|capability|setup|status|list|show CASE|evaluate CASE|evaluate-all|cleanup
This offline model creates no VM, image, network, bridge, tap, process, socket,
load, package, libvirt connection, privilege, host change or external request.
The capability command reads local kernel/filesystem/tool presence only.
EOF
}

command_name="${1:-help}"
case "$command_name" in
  doctor) [[ $# -eq 1 ]] || die arguments; doctor ;;
  capability) [[ $# -eq 1 ]] || die arguments; capability ;;
  setup) [[ $# -eq 1 ]] || die arguments; setup ;;
  status) [[ $# -eq 1 ]] || die arguments; status ;;
  list) [[ $# -eq 1 ]] || die arguments; list_cases ;;
  show) [[ $# -eq 2 ]] || die arguments; show_case "$2" ;;
  evaluate) [[ $# -eq 2 ]] || die arguments; evaluate "$2" ;;
  evaluate-all) [[ $# -eq 1 ]] || die arguments; evaluate_all ;;
  inject-unknown) [[ $# -eq 1 ]] || die arguments; inject_unknown ;;
  clear-unknown) [[ $# -eq 1 ]] || die arguments; clear_unknown ;;
  cleanup) [[ $# -eq 1 ]] || die arguments; cleanup ;;
  help|-h|--help) help_text ;;
  *) die "unknown-command:$command_name" ;;
esac
