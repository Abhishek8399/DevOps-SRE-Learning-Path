#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'; umask 077
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
MODEL="${SCRIPT_DIR}/model.py"; FIXTURE="${SCRIPT_DIR}/fixtures/cases.json"
UID_VALUE="$(id -u)"; ROOT="/tmp/reliability-atlas-les0042-model-${UID_VALUE}"; SENTINEL=".les0042-sentinel"
die(){ printf 'lab=fail reason=%s\n' "$*" >&2; exit 1; }
doctor(){
  (( UID_VALUE > 0 )) || die "root refused"
  grep -Eq '^ID="?ubuntu"?$' /etc/os-release || die "Ubuntu required"
  grep -Eq '^VERSION_ID="?24\.04([^0-9].*)?"?$' /etc/os-release || die "Ubuntu 24.04 required"
  local n; for n in bash python3 cp mkdir chmod rm grep id stat cat; do command -v "$n" >/dev/null || die "missing $n"; done
  python3 -c 'import pathlib,sys; compile(pathlib.Path(sys.argv[1]).read_text(),sys.argv[1],"exec")' "$MODEL"
  python3 -c 'import json,pathlib,sys; json.loads(pathlib.Path(sys.argv[1]).read_text())' "$FIXTURE"
  printf 'doctor=pass runtime=kubernetes-workload-model-only cluster_evidence=false\n'
}
require_state(){ doctor >/dev/null; [[ -d "$ROOT" && ! -L "$ROOT" ]] || die "unsafe or absent root"; python3 "$MODEL" verify "$ROOT" >/dev/null; }
setup(){
  doctor; [[ ! -e "$ROOT" && ! -L "$ROOT" ]] || die "root already exists"
  mkdir -m 0700 -- "$ROOT"; cp -- "$FIXTURE" "$ROOT/cases.json"; chmod 0600 "$ROOT/cases.json"
  printf 'les0042:%s\n' "$UID_VALUE" >"$ROOT/$SENTINEL"; chmod 0600 "$ROOT/$SENTINEL"
  python3 "$MODEL" initialize "$ROOT"; printf 'setup=pass\n'
}
list_cases(){ require_state; python3 "$MODEL" list "$ROOT"; }
diagnose(){ require_state; [[ -n "${1:-}" ]] || die "case required"; python3 "$MODEL" diagnose "$ROOT" "$1"; }
diagnose_as(){ require_state; [[ -n "${1:-}" && -n "${2:-}" ]] || die "case and answer required"; python3 "$MODEL" diagnose "$ROOT" "$1" --answer "$2"; }
verify_cases(){
  require_state; local c
  for c in pending-resources impossible-constraints image-pull crash-loop oom-killed running-not-ready rollout-stalled hpa-capacity; do python3 "$MODEL" diagnose "$ROOT" "$c" >/dev/null; done
  python3 "$MODEL" verify "$ROOT"; printf 'verification=pass cases=8\n'
}
inject_unknown(){ require_state; printf 'refusal\n' >"$ROOT/unexpected.entry"; printf 'unexpected_entry=true\n'; }
clear_unknown(){ local p="$ROOT/unexpected.entry"; [[ -f "$p" && ! -L "$p" ]] || die "test entry unsafe"; [[ "$(stat -c '%u' "$p")" == "$UID_VALUE" ]] || die "owner"; [[ "$(cat "$p")" == refusal ]] || die "content"; rm -f -- "$p"; require_state; }
cleanup(){ (( UID_VALUE > 0 )) || die "root refused"; require_state; rm -rf -- "$ROOT"; [[ ! -e "$ROOT" && ! -L "$ROOT" ]] || die "root remains"; printf 'cleanup=pass state_absent=true\n'; }
case "${1:-}" in
  doctor) doctor;; setup) setup;; list) list_cases;; diagnose) diagnose "${2:-}";; diagnose-as) diagnose_as "${2:-}" "${3:-}";; verify-cases) verify_cases;; inject-unknown) inject_unknown;; clear-unknown) clear_unknown;; cleanup) cleanup;; *) printf '%s\n' 'usage: bash lab.sh {doctor|setup|list|diagnose CASE|diagnose-as CASE ANSWER|verify-cases|inject-unknown|clear-unknown|cleanup}'; exit 2;;
esac
