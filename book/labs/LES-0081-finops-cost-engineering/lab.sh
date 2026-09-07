#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CASES="$DIR/fixtures/cases.json"
LEDGER="$DIR/fixtures/billing.csv"
TARGETS="$DIR/fixtures/targets.json"
MODEL="$DIR/model.py"
STATE="/tmp/reliability-atlas-les0081-finops-$(id -u)"
SENTINEL="$STATE/.les0081"
die(){ printf 'lab=fail reason=%s\n' "$1" >&2; exit 1; }

guard(){
  [[ "$(id -u)" -ne 0 ]] || die root-refused
  command -v python3 >/dev/null 2>&1 || die python3-missing
  [[ -z "${AWS_PROFILE:-}${AWS_ACCESS_KEY_ID:-}${AWS_SECRET_ACCESS_KEY:-}${AWS_SESSION_TOKEN:-}${AZURE_CLIENT_ID:-}${AZURE_CLIENT_SECRET:-}${AZURE_TENANT_ID:-}${GOOGLE_APPLICATION_CREDENTIALS:-}${GOOGLE_CLOUD_PROJECT:-}${CLOUDSDK_CONFIG:-}${KUBECONFIG:-}${DOCKER_HOST:-}${ARM_CLIENT_ID:-}${ARM_CLIENT_SECRET:-}${TF_VAR_billing_account:-}${BILLING_EXPORT_URI:-}${CUR_BUCKET:-}${COST_API_TOKEN:-}" ]] || die credential-or-runtime-authority
  [[ ! -L "$STATE" ]] || die state-symlink
  if [[ -e "$STATE" ]]; then
    [[ -d "$STATE" && -O "$STATE" && -f "$SENTINEL" && ! -L "$SENTINEL" ]] || die state-ownership
    [[ "$(<"$SENTINEL")" == "LES-0081:$(id -u)" ]] || die sentinel
  fi
}

inventory(){
  local item relative
  while IFS= read -r -d '' item; do
    relative="${item#"$STATE"/}"
    case "$relative" in .les0081|cases.json|billing.csv|targets.json) ;; *) die "unknown-artifact:$relative" ;; esac
    [[ ! -L "$item" ]] || die "artifact-symlink:$relative"
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}

doctor(){
  guard
  [[ -r "$CASES" && -r "$LEDGER" && -r "$TARGETS" && -r "$MODEL" ]] || die source
  python3 "$MODEL" validate "$CASES"
  python3 "$MODEL" analyze "$LEDGER" "$TARGETS" >/dev/null
  python3 "$MODEL" allocate "$LEDGER" "$TARGETS" >/dev/null
  python3 "$MODEL" forecast "$TARGETS" >/dev/null
  python3 "$MODEL" commitment "$TARGETS" >/dev/null
  printf 'doctor=pass network=none user=%s cloud_runtime_calls=none\n' "$(id -u)"
}

setup(){
  guard
  [[ ! -e "$STATE" ]] || die state-exists
  (
    umask 077
    mkdir -- "$STATE"
    printf 'LES-0081:%s\n' "$(id -u)" >"$SENTINEL"
    cp -- "$CASES" "$STATE/cases.json"
    cp -- "$LEDGER" "$STATE/billing.csv"
    cp -- "$TARGETS" "$STATE/targets.json"
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
  local count rows
  count="$(python3 "$MODEL" list "$STATE/cases.json" | wc -l | tr -d ' ')"
  rows="$(($(wc -l <"$STATE/billing.csv") - 1))"
  printf 'status=ready cases=%s rows=%s state=%s cloud_runtime_calls=none\n' "$count" "$rows" "$STATE"
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

analyze(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  python3 "$MODEL" analyze "$STATE/billing.csv" "$STATE/targets.json"
}

allocate(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  python3 "$MODEL" allocate "$STATE/billing.csv" "$STATE/targets.json"
}

forecast(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  python3 "$MODEL" forecast "$STATE/targets.json"
}

commitment(){
  guard
  [[ -d "$STATE" ]] || die state-absent
  inventory
  python3 "$MODEL" commitment "$STATE/targets.json"
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
  rm -- "$STATE/cases.json" "$STATE/billing.csv" "$STATE/targets.json" "$SENTINEL"
  rmdir -- "$STATE"
  [[ ! -e "$STATE" && ! -L "$STATE" ]] || die cleanup
  printf 'cleanup=pass absent=true\n'
}

case "${1:-help}" in
  doctor) [[ $# -eq 1 ]] || die arguments; doctor ;;
  setup) [[ $# -eq 1 ]] || die arguments; setup ;;
  status) [[ $# -eq 1 ]] || die arguments; status ;;
  list) [[ $# -eq 1 ]] || die arguments; list_cases ;;
  show) [[ $# -eq 2 ]] || die arguments; show_case "$2" ;;
  evaluate) [[ $# -eq 2 ]] || die arguments; evaluate "$2" ;;
  evaluate-all) [[ $# -eq 1 ]] || die arguments; evaluate_all ;;
  analyze) [[ $# -eq 1 ]] || die arguments; analyze ;;
  allocate) [[ $# -eq 1 ]] || die arguments; allocate ;;
  forecast) [[ $# -eq 1 ]] || die arguments; forecast ;;
  commitment) [[ $# -eq 1 ]] || die arguments; commitment ;;
  inject-unknown) [[ $# -eq 1 ]] || die arguments; inject_unknown ;;
  clear-unknown) [[ $# -eq 1 ]] || die arguments; clear_unknown ;;
  cleanup) [[ $# -eq 1 ]] || die arguments; cleanup ;;
  help|-h|--help) printf '%s\n' 'Usage: bash lab.sh doctor|setup|status|list|show CASE|evaluate CASE|evaluate-all|analyze|allocate|forecast|commitment|cleanup' ;;
  *) die "unknown-command:${1:-}" ;;
esac
