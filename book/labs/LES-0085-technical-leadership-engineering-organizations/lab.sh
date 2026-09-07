#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CASES="$DIR/fixtures/cases.json"
PACKET="$DIR/fixtures/packet.json"
MODEL="$DIR/model.py"
STATE="/tmp/reliability-atlas-les0085-leadership-$(id -u)"
SENTINEL="$STATE/.les0085"
die(){ printf 'lab=fail reason=%s\n' "$1" >&2; exit 1; }

guard(){
  [[ "$(id -u)" -ne 0 ]] || die root-refused
  command -v python3 >/dev/null 2>&1 || die python3-missing
  [[ -z "${AWS_PROFILE:-}${AWS_ACCESS_KEY_ID:-}${AWS_SECRET_ACCESS_KEY:-}${AWS_SESSION_TOKEN:-}${AZURE_CLIENT_ID:-}${AZURE_CLIENT_SECRET:-}${GOOGLE_APPLICATION_CREDENTIALS:-}${KUBECONFIG:-}${DOCKER_HOST:-}${HR_SYSTEM_TOKEN:-}${MESSAGING_TOKEN:-}${TICKET_SYSTEM_TOKEN:-}${CALENDAR_TOKEN:-}${PRODUCTION_ENDPOINT:-}" ]] || die credential-or-external-authority
  [[ ! -L "$STATE" ]] || die state-symlink
  if [[ -e "$STATE" ]]; then
    [[ -d "$STATE" && -O "$STATE" && -f "$SENTINEL" && ! -L "$SENTINEL" ]] || die state-ownership
    [[ "$(<"$SENTINEL")" == "LES-0085:$(id -u)" ]] || die sentinel
  fi
}

inventory_state(){
  local item relative
  while IFS= read -r -d '' item; do
    relative="${item#"$STATE"/}"
    case "$relative" in .les0085|cases.json|packet.json) ;; *) die "unknown-artifact:$relative" ;; esac
    [[ ! -L "$item" ]] || die "artifact-symlink:$relative"
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}

doctor(){
  guard
  [[ -r "$CASES" && -r "$PACKET" && -r "$MODEL" ]] || die source
  python3 "$MODEL" validate "$CASES" "$PACKET"
  for action in roadmap priorities delegation decisions stakeholders load; do python3 "$MODEL" "$action" "$PACKET" >/dev/null; done
  printf 'doctor=pass network=none user=%s people_system_calls=none messaging_calls=none runtime_calls=none\n' "$(id -u)"
}

setup(){
  guard
  [[ ! -e "$STATE" ]] || die state-exists
  ( umask 077; mkdir -- "$STATE"; printf 'LES-0085:%s\n' "$(id -u)" >"$SENTINEL"; cp -- "$CASES" "$STATE/cases.json"; cp -- "$PACKET" "$STATE/packet.json" )
  guard; inventory_state
  python3 "$MODEL" validate "$STATE/cases.json" "$STATE/packet.json"
  printf 'setup=pass state=%s\n' "$STATE"
}

status(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory_state
  local count packet_id
  count="$(python3 "$MODEL" list "$STATE/cases.json" | wc -l | tr -d ' ')"
  packet_id="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["packet_id"])' "$STATE/packet.json")"
  printf 'status=ready cases=%s packet_id=%s state=%s people_system_calls=none runtime_calls=none\n' "$count" "$packet_id" "$STATE"
}

run_model(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory_state; python3 "$MODEL" "$@"; }
inject_unknown(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory_state; printf 'preserve-me\n' >"$STATE/unknown"; printf 'inject=pass artifact=unknown\n'; }
clear_unknown(){ guard; [[ -f "$STATE/unknown" && ! -L "$STATE/unknown" ]] || die unknown-missing; rm -- "$STATE/unknown"; inventory_state; printf 'clear=pass artifact=unknown\n'; }
cleanup(){
  guard
  if [[ ! -d "$STATE" ]]; then printf 'cleanup=pass absent=true\n'; return; fi
  inventory_state
  rm -- "$STATE/cases.json" "$STATE/packet.json" "$SENTINEL"
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
  roadmap|priorities|delegation|decisions|stakeholders|load) [[ $# -eq 1 ]] || die arguments; run_model "$1" "$STATE/packet.json" ;;
  inject-unknown) [[ $# -eq 1 ]] || die arguments; inject_unknown ;;
  clear-unknown) [[ $# -eq 1 ]] || die arguments; clear_unknown ;;
  cleanup) [[ $# -eq 1 ]] || die arguments; cleanup ;;
  help|-h|--help) printf '%s\n' 'Usage: bash lab.sh doctor|setup|status|list|show CASE|evaluate CASE|evaluate-all|roadmap|priorities|delegation|decisions|stakeholders|load|cleanup' ;;
  *) die "unknown-command:${1:-}" ;;
esac
