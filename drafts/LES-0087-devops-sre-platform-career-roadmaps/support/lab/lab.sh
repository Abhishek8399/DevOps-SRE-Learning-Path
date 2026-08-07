#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
MODEL="$ROOT/model.py"
CASES="$ROOT/fixtures/cases.json"
PACKET="$ROOT/fixtures/packet.json"
STATE="/tmp/reliability-atlas-les0087-career-$(id -u)"
SENTINEL=".les0087"

die(){ printf 'lab=fail reason=%s\n' "$1" >&2; exit 77; }

guard(){
  [[ "$(id -u)" -ne 0 ]] || die root-refused
  command -v python3 >/dev/null 2>&1 || die python3-missing
  [[ -z "${AWS_PROFILE:-}${AWS_ACCESS_KEY_ID:-}${AWS_SECRET_ACCESS_KEY:-}${AWS_SESSION_TOKEN:-}${AZURE_CLIENT_ID:-}${AZURE_CLIENT_SECRET:-}${GOOGLE_APPLICATION_CREDENTIALS:-}${KUBECONFIG:-}${DOCKER_HOST:-}${ATS_TOKEN:-}${HR_SYSTEM_TOKEN:-}${RESUME_PATH:-}${PORTFOLIO_SECRET_PATH:-}${INTERVIEW_RECORDING_PATH:-}${LIVE_INTERVIEW_TOKEN:-}${OPENAI_API_KEY:-}${ANTHROPIC_API_KEY:-}${PRODUCTION_ENDPOINT:-}" ]] || die credential-private-data-or-external-authority
  [[ ! -L "$STATE" ]] || die state-symlink
  if [[ -e "$STATE" ]]; then
    [[ -d "$STATE" ]] || die state-not-directory
    [[ "$(stat -c '%u' "$STATE")" -eq "$(id -u)" ]] || die state-owner
  fi
}

inventory(){
  [[ -f "$STATE/$SENTINEL" && ! -L "$STATE/$SENTINEL" ]] || die sentinel
  local item relative
  while IFS= read -r -d '' item; do
    relative="${item#"$STATE"/}"
    case "$relative" in "$SENTINEL"|cases.json|packet.json) ;; *) die "unknown-artifact:$relative" ;; esac
    [[ ! -L "$item" ]] || die "artifact-symlink:$relative"
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}

doctor(){
  guard
  python3 "$MODEL" validate "$CASES" "$PACKET"
  printf 'doctor=pass network=none user=%s learner_evaluation=none level_inference=none hiring_prediction=none external_calls=none\n' "$(id -u)"
}

setup(){
  guard
  [[ ! -e "$STATE" ]] || die state-exists
  mkdir -m 700 -- "$STATE"
  printf 'LES-0087\n' >"$STATE/$SENTINEL"
  cp -- "$CASES" "$STATE/cases.json"
  cp -- "$PACKET" "$STATE/packet.json"
  chmod 600 "$STATE/$SENTINEL" "$STATE/cases.json" "$STATE/packet.json"
  inventory
  python3 "$MODEL" validate "$STATE/cases.json" "$STATE/packet.json"
  printf 'setup=pass state=%s\n' "$STATE"
}

status(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  local count packet
  count="$(python3 -c 'import json,sys; print(sum(len(g["cases"]) for g in json.load(open(sys.argv[1]))["gate_groups"]))' "$STATE/cases.json")"
  packet="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["packet_id"])' "$STATE/packet.json")"
  printf 'status=pass cases=%s packet=%s state=%s\n' "$count" "$packet" "$STATE"
}

run_model(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; python3 "$MODEL" "$@"; }
inject_unknown(){ guard; [[ -d "$STATE" ]] || die state-absent; inventory; printf 'preserve-me\n' >"$STATE/unknown"; printf 'inject=pass artifact=unknown\n'; }
clear_unknown(){ guard; [[ -f "$STATE/unknown" && ! -L "$STATE/unknown" ]] || die unknown-missing; rm -- "$STATE/unknown"; inventory; printf 'clear=pass artifact=unknown\n'; }

cleanup(){
  guard
  [[ -e "$STATE" ]] || { printf 'cleanup=pass absent=true\n'; return; }
  inventory
  rm -- "$STATE/$SENTINEL" "$STATE/cases.json" "$STATE/packet.json"
  rmdir -- "$STATE"
  [[ ! -e "$STATE" ]] || die cleanup-not-absent
  printf 'cleanup=pass absent=true\n'
}

case "${1:-}" in
  doctor) [[ $# -eq 1 ]] || die arguments; doctor ;;
  setup) [[ $# -eq 1 ]] || die arguments; setup ;;
  status) [[ $# -eq 1 ]] || die arguments; status ;;
  roadmap) [[ $# -eq 1 ]] || die arguments; run_model roadmap "$STATE/cases.json" ;;
  show|evaluate) [[ $# -eq 2 ]] || die arguments; run_model "$1" "$STATE/cases.json" "$2" ;;
  evaluate-all) [[ $# -eq 1 ]] || die arguments; run_model evaluate-all "$STATE/cases.json" ;;
  roles|evidence|dependencies|capacity|milestones|reviews) [[ $# -eq 1 ]] || die arguments; run_model "$1" "$STATE/packet.json" ;;
  inject-unknown) [[ $# -eq 1 ]] || die arguments; inject_unknown ;;
  clear-unknown) [[ $# -eq 1 ]] || die arguments; clear_unknown ;;
  cleanup) [[ $# -eq 1 ]] || die arguments; cleanup ;;
  help|-h|--help) printf '%s\n' 'Usage: bash lab.sh doctor|setup|status|roadmap|show CASE|evaluate CASE|evaluate-all|roles|evidence|dependencies|capacity|milestones|reviews|cleanup' ;;
  *) die "unknown-command:${1:-}" ;;
esac
