#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'; umask 077
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"; MODEL="$DIR/model.py"; FIXTURE="$DIR/fixtures/cases.json"; UID_NOW="$(id -u)"; ROOT="/tmp/reliability-atlas-les0046-model-$UID_NOW"
die(){ printf 'lab=fail reason=%s\n' "$*" >&2; exit 1; }
doctor(){ ((UID_NOW>0))||die root; grep -Eq '^ID="?ubuntu"?$' /etc/os-release||die ubuntu; grep -Eq '^VERSION_ID="?24\.04' /etc/os-release||die version; python3 -c 'import pathlib,sys;compile(pathlib.Path(sys.argv[1]).read_text(),sys.argv[1],"exec")' "$MODEL"; printf 'doctor=pass runtime=packaging-release-model-only\n'; }
need(){ doctor>/dev/null; [[ -d "$ROOT" && ! -L "$ROOT" ]]||die state; python3 "$MODEL" verify "$ROOT">/dev/null; }
setup(){ doctor; [[ ! -e "$ROOT" && ! -L "$ROOT" ]]||die exists; mkdir -m 0700 "$ROOT"; cp "$FIXTURE" "$ROOT/cases.json"; printf 'les0046:%s\n' "$UID_NOW">"$ROOT/.les0046-sentinel"; chmod 0600 "$ROOT"/* "$ROOT/.les0046-sentinel"; python3 "$MODEL" init "$ROOT"; }
all(){ need; for case_name in values-type-drift rendered-name-collision selector-drift hook-side-effect crd-ordering partial-upgrade rollback-incompatibility overlay-ownership-conflict; do python3 "$MODEL" diagnose "$ROOT" "$case_name">/dev/null; done; python3 "$MODEL" verify "$ROOT"; }
cleanup(){ need; rm -rf -- "$ROOT"; [[ ! -e "$ROOT" ]]||die remains; printf 'cleanup=pass state_absent=true\n'; }
case "${1:-}" in doctor)doctor;; setup)setup;; list)need;python3 "$MODEL" list "$ROOT";; diagnose)need;python3 "$MODEL" diagnose "$ROOT" "${2:-}";; diagnose-as)need;python3 "$MODEL" diagnose "$ROOT" "${2:-}" --answer "${3:-}";; verify-cases)all;; inject-unknown)need;printf x>"$ROOT/unexpected";; clear-unknown)rm -f "$ROOT/unexpected";need;; cleanup)cleanup;; *)exit 2;; esac
