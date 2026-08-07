#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
FIXTURE="$DIR/fixtures/cases.json"
MODEL="$DIR/model.py"
STATE="/tmp/reliability-atlas-les0074-recovery-$(id -u)"
SENTINEL="$STATE/.les0074"

die(){ printf 'lab=fail reason=%s\n' "$1" >&2; exit 1; }

guard(){
  [[ "$(id -u)" -ne 0 ]] || die root-refused
  command -v python3 >/dev/null 2>&1 || die python3-missing
  [[ -z "${AWS_PROFILE:-}${AWS_ACCESS_KEY_ID:-}${AZURE_CLIENT_SECRET:-}${GOOGLE_APPLICATION_CREDENTIALS:-}${KUBECONFIG:-}${DOCKER_HOST:-}" ]] || die credential-or-external-endpoint
  [[ ! -L "$STATE" ]] || die state-symlink
  if [[ -e "$STATE" ]]; then
    [[ -d "$STATE" && -O "$STATE" && -f "$SENTINEL" && ! -L "$SENTINEL" ]] || die state-ownership
    [[ "$(<"$SENTINEL")" == "LES-0074:$(id -u)" ]] || die sentinel
  fi
}

inventory(){
  local item relative
  while IFS= read -r -d '' item; do
    relative="${item#"$STATE"/}"
    case "$relative" in
      .les0074|cases.json) ;;
      *) die "unknown-artifact:$relative" ;;
    esac
    [[ ! -L "$item" ]] || die "artifact-symlink:$relative"
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}

doctor(){
  guard
  [[ -r "$FIXTURE" && -r "$MODEL" ]] || die source
  python3 "$MODEL" validate "$FIXTURE"
  printf 'doctor=pass network=none user=%s\n' "$(id -u)"
}

setup(){
  guard
  [[ ! -e "$STATE" ]] || die state-exists
  (
    umask 077
    mkdir -- "$STATE"
    printf 'LES-0074:%s\n' "$(id -u)" >"$SENTINEL"
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
  printf 'status=ready cases=%s state=%s\n' "$count" "$STATE"
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
  [[ -d "$STATE" ]] || { printf 'cleanup=pass absent=true\n'; return; }
  inventory
  rm -- "$STATE/cases.json" "$SENTINEL"
  rmdir -- "$STATE"
  [[ ! -e "$STATE" && ! -L "$STATE" ]] || die cleanup
  printf 'cleanup=pass absent=true\n'
}

help_text(){
  cat <<'EOF'
Usage: bash lab.sh COMMAND [CASE]

Commands:
  doctor        prove local normal-user/offline prerequisites
  setup         create one exact UID-scoped synthetic state directory
  status        report model case count and state path
  list          list all synthetic recovery cases
  show CASE     print the merged candidate for one case
  evaluate CASE report the first failed recovery evidence boundary
  evaluate-all  evaluate all 45 cases
  cleanup       remove only the two allowlisted lab artifacts

This model performs no backup, restore, failover, routing, service, cloud,
container, Kubernetes, database, privilege or host-configuration action.
EOF
}

command_name="${1:-help}"
case "$command_name" in
  doctor) [[ $# -eq 1 ]] || die arguments; doctor ;;
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
