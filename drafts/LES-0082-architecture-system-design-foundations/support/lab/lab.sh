#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CASES="$DIR/fixtures/cases.json"
DESIGN="$DIR/fixtures/design.json"
MODEL="$DIR/model.py"
STATE="/tmp/reliability-atlas-les0082-architecture-$(id -u)"
SENTINEL="$STATE/.les0082"
die(){ printf 'lab=fail reason=%s\n' "$1" >&2; exit 1; }

guard(){
  [[ "$(id -u)" -ne 0 ]] || die root-refused
  command -v python3 >/dev/null 2>&1 || die python3-missing
  [[ -z "${AWS_PROFILE:-}${AWS_ACCESS_KEY_ID:-}${AWS_SECRET_ACCESS_KEY:-}${AWS_SESSION_TOKEN:-}${AZURE_CLIENT_ID:-}${AZURE_CLIENT_SECRET:-}${AZURE_TENANT_ID:-}${GOOGLE_APPLICATION_CREDENTIALS:-}${GOOGLE_CLOUD_PROJECT:-}${KUBECONFIG:-}${DOCKER_HOST:-}${ARM_CLIENT_ID:-}${ARM_CLIENT_SECRET:-}${TF_VAR_project_id:-}${ARCHITECTURE_RUNTIME_URI:-}${PRODUCTION_ENDPOINT:-}" ]] || die credential-or-runtime-authority
  [[ ! -L "$STATE" ]] || die state-symlink
  if [[ -e "$STATE" ]]; then
    [[ -d "$STATE" && -O "$STATE" && -f "$SENTINEL" && ! -L "$SENTINEL" ]] || die state-ownership
    [[ "$(<"$SENTINEL")" == "LES-0082:$(id -u)" ]] || die sentinel
  fi
}

inventory(){
  local item relative
  while IFS= read -r -d '' item; do
    relative="${item#"$STATE"/}"
    case "$relative" in .les0082|cases.json|design.json) ;; *) die "unknown-artifact:$relative" ;; esac
    [[ ! -L "$item" ]] || die "artifact-symlink:$relative"
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}

doctor(){
  guard
  [[ -r "$CASES" && -r "$DESIGN" && -r "$MODEL" ]] || die source
  python3 "$MODEL" validate "$CASES" "$DESIGN"
  python3 "$MODEL" map "$DESIGN" >/dev/null
  python3 "$MODEL" capacity "$DESIGN" >/dev/null
  python3 "$MODEL" availability "$DESIGN" >/dev/null
  python3 "$MODEL" backlog "$DESIGN" >/dev/null
  python3 "$MODEL" latency "$DESIGN" >/dev/null
  python3 "$MODEL" tradeoff "$DESIGN" >/dev/null
  printf 'doctor=pass network=none user=%s runtime_calls=none\n' "$(id -u)"
}

setup(){
  guard
  [[ ! -e "$STATE" ]] || die state-exists
  (
    umask 077
    mkdir -- "$STATE"
    printf 'LES-0082:%s\n' "$(id -u)" >"$SENTINEL"
    cp -- "$CASES" "$STATE/cases.json"
    cp -- "$DESIGN" "$STATE/design.json"
  )
  guard
  inventory
  python3 "$MODEL" validate "$STATE/cases.json" "$STATE/design.json"
  printf 'setup=pass state=%s\n' "$STATE"
}

status(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  local count design_id
  count="$(python3 "$MODEL" list "$STATE/cases.json" | wc -l | tr -d ' ')"
  design_id="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["design_id"])' "$STATE/design.json")"
  printf 'status=ready cases=%s design_id=%s state=%s runtime_calls=none\n' "$count" "$design_id" "$STATE"
}

run_model(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  python3 "$MODEL" "$@"
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
  rm -- "$STATE/cases.json" "$STATE/design.json" "$SENTINEL"
  rmdir -- "$STATE"
  [[ ! -e "$STATE" && ! -L "$STATE" ]] || die cleanup
  printf 'cleanup=pass absent=true\n'
}

case "${1:-help}" in
  doctor) [[ $# -eq 1 ]] || die arguments; doctor ;;
  setup) [[ $# -eq 1 ]] || die arguments; setup ;;
  status) [[ $# -eq 1 ]] || die arguments; status ;;
  list) [[ $# -eq 1 ]] || die arguments; run_model list "$STATE/cases.json" ;;
  show) [[ $# -eq 2 ]] || die arguments; run_model show "$STATE/cases.json" "$2" ;;
  evaluate) [[ $# -eq 2 ]] || die arguments; run_model evaluate "$STATE/cases.json" "$2" ;;
  evaluate-all) [[ $# -eq 1 ]] || die arguments; run_model evaluate-all "$STATE/cases.json" ;;
  map) [[ $# -eq 1 ]] || die arguments; run_model map "$STATE/design.json" ;;
  capacity) [[ $# -eq 1 ]] || die arguments; run_model capacity "$STATE/design.json" ;;
  availability) [[ $# -eq 1 ]] || die arguments; run_model availability "$STATE/design.json" ;;
  backlog) [[ $# -eq 1 ]] || die arguments; run_model backlog "$STATE/design.json" ;;
  latency) [[ $# -eq 1 ]] || die arguments; run_model latency "$STATE/design.json" ;;
  tradeoff) [[ $# -eq 1 ]] || die arguments; run_model tradeoff "$STATE/design.json" ;;
  inject-unknown) [[ $# -eq 1 ]] || die arguments; inject_unknown ;;
  clear-unknown) [[ $# -eq 1 ]] || die arguments; clear_unknown ;;
  cleanup) [[ $# -eq 1 ]] || die arguments; cleanup ;;
  help|-h|--help) printf '%s\n' 'Usage: bash lab.sh doctor|setup|status|list|show CASE|evaluate CASE|evaluate-all|map|capacity|availability|backlog|latency|tradeoff|cleanup' ;;
  *) die "unknown-command:${1:-}" ;;
esac
