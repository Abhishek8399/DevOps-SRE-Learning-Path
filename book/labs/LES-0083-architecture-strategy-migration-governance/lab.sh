#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CASES="$DIR/fixtures/cases.json"
STRATEGY="$DIR/fixtures/strategy.json"
MODEL="$DIR/model.py"
STATE="/tmp/reliability-atlas-les0083-strategy-$(id -u)"
SENTINEL="$STATE/.les0083"
die(){ printf 'lab=fail reason=%s\n' "$1" >&2; exit 1; }

guard(){
  [[ "$(id -u)" -ne 0 ]] || die root-refused
  command -v python3 >/dev/null 2>&1 || die python3-missing
  [[ -z "${AWS_PROFILE:-}${AWS_ACCESS_KEY_ID:-}${AWS_SECRET_ACCESS_KEY:-}${AWS_SESSION_TOKEN:-}${AZURE_CLIENT_ID:-}${AZURE_CLIENT_SECRET:-}${AZURE_TENANT_ID:-}${GOOGLE_APPLICATION_CREDENTIALS:-}${GOOGLE_CLOUD_PROJECT:-}${KUBECONFIG:-}${DOCKER_HOST:-}${ARM_CLIENT_ID:-}${ARM_CLIENT_SECRET:-}${TF_VAR_project_id:-}${MIGRATION_RUNTIME_URI:-}${PRODUCTION_ENDPOINT:-}${VENDOR_API_TOKEN:-}" ]] || die credential-or-runtime-authority
  [[ ! -L "$STATE" ]] || die state-symlink
  if [[ -e "$STATE" ]]; then
    [[ -d "$STATE" && -O "$STATE" && -f "$SENTINEL" && ! -L "$SENTINEL" ]] || die state-ownership
    [[ "$(<"$SENTINEL")" == "LES-0083:$(id -u)" ]] || die sentinel
  fi
}

inventory_state(){
  local item relative
  while IFS= read -r -d '' item; do
    relative="${item#"$STATE"/}"
    case "$relative" in .les0083|cases.json|strategy.json) ;; *) die "unknown-artifact:$relative" ;; esac
    [[ ! -L "$item" ]] || die "artifact-symlink:$relative"
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}

doctor(){
  guard
  [[ -r "$CASES" && -r "$STRATEGY" && -r "$MODEL" ]] || die source
  python3 "$MODEL" validate "$CASES" "$STRATEGY"
  for action in roadmap inventory capacity transfer economics vendor; do python3 "$MODEL" "$action" "$STRATEGY" >/dev/null; done
  printf 'doctor=pass network=none user=%s runtime_calls=none\n' "$(id -u)"
}

setup(){
  guard
  [[ ! -e "$STATE" ]] || die state-exists
  ( umask 077; mkdir -- "$STATE"; printf 'LES-0083:%s\n' "$(id -u)" >"$SENTINEL"; cp -- "$CASES" "$STATE/cases.json"; cp -- "$STRATEGY" "$STATE/strategy.json" )
  guard; inventory_state
  python3 "$MODEL" validate "$STATE/cases.json" "$STATE/strategy.json"
  printf 'setup=pass state=%s\n' "$STATE"
}

status(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory_state
  local count strategy_id
  count="$(python3 "$MODEL" list "$STATE/cases.json" | wc -l | tr -d ' ')"
  strategy_id="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["strategy_id"])' "$STATE/strategy.json")"
  printf 'status=ready cases=%s strategy_id=%s state=%s runtime_calls=none\n' "$count" "$strategy_id" "$STATE"
}

run_model(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory_state; python3 "$MODEL" "$@"; }
inject_unknown(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory_state; printf 'do-not-delete\n' >"$STATE/unknown"; printf 'inject=pass artifact=unknown\n'; }
clear_unknown(){ guard; [[ -f "$STATE/unknown" && ! -L "$STATE/unknown" ]] || die unknown-missing; rm -- "$STATE/unknown"; inventory_state; printf 'clear=pass artifact=unknown\n'; }
cleanup(){
  guard
  if [[ ! -d "$STATE" ]]; then printf 'cleanup=pass absent=true\n'; return; fi
  inventory_state
  rm -- "$STATE/cases.json" "$STATE/strategy.json" "$SENTINEL"
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
  roadmap|inventory|capacity|transfer|economics|vendor) [[ $# -eq 1 ]] || die arguments; run_model "$1" "$STATE/strategy.json" ;;
  inject-unknown) [[ $# -eq 1 ]] || die arguments; inject_unknown ;;
  clear-unknown) [[ $# -eq 1 ]] || die arguments; clear_unknown ;;
  cleanup) [[ $# -eq 1 ]] || die arguments; cleanup ;;
  help|-h|--help) printf '%s\n' 'Usage: bash lab.sh doctor|setup|status|list|show CASE|evaluate CASE|evaluate-all|roadmap|inventory|capacity|transfer|economics|vendor|cleanup' ;;
  *) die "unknown-command:${1:-}" ;;
esac
