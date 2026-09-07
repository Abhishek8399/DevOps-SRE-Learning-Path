#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
UID_NOW="$(id -u)"
STATE="/tmp/reliability-atlas-les0064-workflow-ml-platform-$UID_NOW"
SENTINEL="$STATE/.les0064-sentinel"
FIXTURE="$STATE/cases.json"
MODEL="$DIR/model.py"

die(){ printf 'lab=fail reason=%s\n' "$*" >&2; exit 1; }
doctor(){
  (( UID_NOW > 0 ))||die root
  grep -Eq '^ID="?ubuntu"?$' /etc/os-release||die ubuntu
  grep -Eq '^VERSION_ID="?24\.04' /etc/os-release||die version
  [[ -z "${AWS_ACCESS_KEY_ID:-}${AZURE_CLIENT_SECRET:-}${GOOGLE_APPLICATION_CREDENTIALS:-}${KUBECONFIG:-}${AIRFLOW__DATABASE__SQL_ALCHEMY_CONN:-}${AIRFLOW_CONN_DEFAULT:-}${MLFLOW_TRACKING_URI:-}${MLFLOW_TRACKING_TOKEN:-}${JUPYTER_TOKEN:-}" ]]||die credential
  command -v python3 >/dev/null||die python
  printf 'doctor=pass runtime=offline-workflow-ml-platform-model\n'
}
guard(){
  [[ "$STATE" == "/tmp/reliability-atlas-les0064-workflow-ml-platform-$UID_NOW" ]]||die unsafe-root
  [[ -d "$STATE" && ! -L "$STATE" ]]||die state
  [[ "$(stat -c %u "$STATE")" == "$UID_NOW" ]]||die owner
  [[ -f "$SENTINEL" && ! -L "$SENTINEL" && "$(<"$SENTINEL")" == "les0064:$UID_NOW" ]]||die sentinel
  while IFS= read -r -d '' entry; do
    [[ ! -L "$entry" ]]||die child-symlink
    case "$(basename -- "$entry")" in .les0064-sentinel|cases.json) ;; *) die unexpected-artifact;; esac
  done < <(find "$STATE" -mindepth 1 -maxdepth 1 -print0)
}
setup(){
  doctor
  [[ ! -e "$STATE" && ! -L "$STATE" ]]||die exists
  mkdir -m 0700 "$STATE"
  printf 'les0064:%s\n' "$UID_NOW" >"$SENTINEL"
  cp -- "$DIR/fixtures/cases.json" "$FIXTURE"
  chmod 0600 "$SENTINEL" "$FIXTURE"
  guard
  python3 "$MODEL" validate "$FIXTURE"
  printf 'setup=pass state=%s network=none\n' "$STATE"
}
need(){ doctor >/dev/null; guard; python3 "$MODEL" validate "$FIXTURE" >/dev/null; }
status(){ need; printf 'status=ready cases=%s network=none\n' "$(python3 "$MODEL" list "$FIXTURE"|wc -l)"; }
show(){ need; python3 "$MODEL" show "$FIXTURE" "${2:?case required}"; }
evaluate(){ need; python3 "$MODEL" evaluate "$FIXTURE" "${2:?case required}"; }
inject_unknown(){ need; printf 'unexpected\n' >"$STATE/unexpected"; }
clear_unknown(){
  [[ "$STATE" == "/tmp/reliability-atlas-les0064-workflow-ml-platform-$UID_NOW" && -d "$STATE" && ! -L "$STATE" ]]||die unsafe-clear
  [[ -f "$STATE/unexpected" && ! -L "$STATE/unexpected" && "$(stat -c %u "$STATE/unexpected")" == "$UID_NOW" ]]||die unknown-shape
  rm -f -- "$STATE/unexpected"
  need
}
cleanup(){
  need
  rm -f -- "$FIXTURE" "$SENTINEL"
  rmdir -- "$STATE"
  [[ ! -e "$STATE" && ! -L "$STATE" ]]||die remains
  printf 'cleanup=pass state_absent=true\n'
}
case "${1:-}" in
  doctor) doctor;;
  setup) setup;;
  status) status;;
  show) show "$@";;
  evaluate) evaluate "$@";;
  inject-unknown) inject_unknown;;
  clear-unknown) clear_unknown;;
  cleanup) cleanup;;
  *) exit 2;;
esac
