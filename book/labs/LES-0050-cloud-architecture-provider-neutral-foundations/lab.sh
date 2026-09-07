#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077
D="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
M="$D/model.py"
F="$D/fixtures/architecture.json"
U="$(id -u)"
R="/tmp/reliability-atlas-les0050-model-$U"
die(){ printf 'lab=fail reason=%s\n' "$*" >&2; exit 1; }
doctor(){
  (( U > 0 )) || die root
  grep -Eq '^ID="?ubuntu"?$' /etc/os-release || die ubuntu
  grep -Eq '^VERSION_ID="?24\.04' /etc/os-release || die version
  [[ -z "${AWS_ACCESS_KEY_ID:-}${AWS_PROFILE:-}${AZURE_CONFIG_DIR:-}${GOOGLE_APPLICATION_CREDENTIALS:-}" ]] || die credential
  python3 -c 'import pathlib,sys;compile(pathlib.Path(sys.argv[1]).read_text(),sys.argv[1],"exec")' "$M"
  printf 'doctor=pass runtime=provider-neutral-model-only\n'
}
need(){ doctor >/dev/null; [[ -d "$R" && ! -L "$R" ]] || die state; python3 "$M" status "$R" >/dev/null; }
setup(){
  doctor
  [[ ! -e "$R" && ! -L "$R" ]] || die exists
  mkdir -m 0700 "$R"
  cp "$F" "$R/architecture.json"
  printf 'les0050:%s\n' "$U" >"$R/.les0050-sentinel"
  chmod 0600 "$R"/* "$R/.les0050-sentinel"
  python3 "$M" init "$R"
}
show(){ need; python3 "$M" show "$R/architecture.json"; }
evaluate(){ need; python3 "$M" evaluate "$R/architecture.json"; }
scenario(){ need; python3 "$M" scenario "$R/architecture.json" "${1:-}"; }
status(){ need; python3 "$M" status "$R"; }
cleanup(){ need; rm -rf -- "$R"; [[ ! -e "$R" ]] || die remains; printf 'cleanup=pass state_absent=true\n'; }
clear_unknown(){
  [[ "$R" == "/tmp/reliability-atlas-les0050-model-$U" && -d "$R" && ! -L "$R" && "$(stat -c %u "$R")" == "$U" ]] || die unsafe-clear
  [[ -f "$R/unexpected" && ! -L "$R/unexpected" ]] || die unknown-shape
  rm -f -- "$R/unexpected"
  need
}
case "${1:-}" in
  doctor) doctor ;;
  setup) setup ;;
  show) show ;;
  evaluate) evaluate ;;
  scenario) scenario "${2:-}" ;;
  status) status ;;
  inject-unknown) need; printf x >"$R/unexpected" ;;
  clear-unknown) clear_unknown ;;
  cleanup) cleanup ;;
  *) exit 2 ;;
esac
