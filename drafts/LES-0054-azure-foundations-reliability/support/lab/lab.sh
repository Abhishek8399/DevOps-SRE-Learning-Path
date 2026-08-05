#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
MODEL="$DIR/model.py"; FIXTURE="$DIR/fixtures/cases.json"; UID_NOW="$(id -u)"
ROOT="/tmp/reliability-atlas-les0054-model-$UID_NOW"
die(){ printf 'lab=fail reason=%s\n' "$*" >&2; exit 1; }
doctor(){
  ((UID_NOW>0))||die root
  grep -Eq '^ID="?ubuntu"?$' /etc/os-release||die ubuntu
  grep -Eq '^VERSION_ID="?24\.04' /etc/os-release||die version
  [[ -z "${AZURE_CLIENT_ID:-}${AZURE_CLIENT_SECRET:-}${AZURE_TENANT_ID:-}${AZURE_SUBSCRIPTION_ID:-}${AZURE_CONFIG_DIR:-}" ]]||die credential
  command -v python3 >/dev/null||die python
  python3 -c 'import pathlib,sys;compile(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"),sys.argv[1],"exec")' "$MODEL"
  python3 -m json.tool "$FIXTURE">/dev/null
  printf 'doctor=pass runtime=azure-readiness-model-only\n'
}
need(){ doctor>/dev/null; [[ -d "$ROOT"&&! -L "$ROOT" ]]||die state; python3 "$MODEL" status "$ROOT">/dev/null; }
setup(){ doctor; [[ ! -e "$ROOT"&&! -L "$ROOT" ]]||die exists; mkdir -m 0700 "$ROOT"; cp -- "$FIXTURE" "$ROOT/cases.json"; printf 'les0054:%s\n' "$UID_NOW">"$ROOT/.les0054-sentinel"; chmod 0600 "$ROOT/cases.json" "$ROOT/.les0054-sentinel"; python3 "$MODEL" init "$ROOT"; }
cleanup(){ need; rm -rf -- "$ROOT"; [[ ! -e "$ROOT"&&! -L "$ROOT" ]]||die remains; printf 'cleanup=pass state_absent=true\n'; }
inject_unknown(){ need; printf 'unexpected\n'>"$ROOT/unexpected"; }
clear_unknown(){ [[ "$ROOT" == "/tmp/reliability-atlas-les0054-model-$UID_NOW"&&-d "$ROOT"&&! -L "$ROOT" ]]||die unsafe-clear; [[ "$(stat -c %u "$ROOT")" == "$UID_NOW" ]]||die unsafe-owner; [[ -f "$ROOT/unexpected"&&! -L "$ROOT/unexpected" ]]||die unknown-shape; rm -f -- "$ROOT/unexpected"; need; }
case "${1:-}" in
 doctor)doctor;; setup)setup;; list)need;python3 "$MODEL" list "$ROOT/cases.json";; show)need;python3 "$MODEL" show "$ROOT/cases.json" "${2:-baseline}";; evaluate)need;python3 "$MODEL" evaluate "$ROOT/cases.json" "${2:-baseline}";; status)need;python3 "$MODEL" status "$ROOT";; inject-unknown)inject_unknown;; clear-unknown)clear_unknown;; cleanup)cleanup;; *)exit 2;;
esac

