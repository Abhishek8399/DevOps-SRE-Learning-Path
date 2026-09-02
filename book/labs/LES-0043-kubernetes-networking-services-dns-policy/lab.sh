#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'; umask 077
D="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"; M="$D/model.py"; F="$D/fixtures/cases.json"; U="$(id -u)"; R="/tmp/reliability-atlas-les0043-model-$U"
die(){ printf 'lab=fail reason=%s\n' "$*" >&2; exit 1; }
doctor(){ ((U>0))||die root; grep -Eq '^ID="?ubuntu"?$' /etc/os-release||die ubuntu; grep -Eq '^VERSION_ID="?24\.04([^0-9].*)?"?$' /etc/os-release||die version; for n in bash python3 cp mkdir chmod rm grep id stat cat; do command -v "$n" >/dev/null||die "missing $n"; done; python3 -c 'import pathlib,sys;compile(pathlib.Path(sys.argv[1]).read_text(),sys.argv[1],"exec")' "$M"; printf 'doctor=pass runtime=kubernetes-network-model-only\n'; }
need(){ doctor >/dev/null; [[ -d "$R"&&! -L "$R" ]]||die state; python3 "$M" verify "$R" >/dev/null; }
setup(){ doctor; [[ ! -e "$R"&&! -L "$R" ]]||die exists; mkdir -m 0700 "$R"; cp "$F" "$R/cases.json"; printf 'les0043:%s\n' "$U">"$R/.les0043-sentinel"; chmod 0600 "$R"/* "$R/.les0043-sentinel"; python3 "$M" init "$R"; }
all(){ need; for c in dns-nxdomain service-no-endpoints wrong-target-port policy-deny vip-only-failure cross-node-mtu gateway-rejected; do python3 "$M" diagnose "$R" "$c">/dev/null; done; python3 "$M" verify "$R"; printf 'verification=pass cases=7\n'; }
cleanup(){ ((U>0))||die root; need; rm -rf -- "$R"; [[ ! -e "$R"&&! -L "$R" ]]||die remains; printf 'cleanup=pass state_absent=true\n'; }
case "${1:-}" in doctor)doctor;;setup)setup;;list)need;python3 "$M" list "$R";;diagnose)need;python3 "$M" diagnose "$R" "${2:-}";;diagnose-as)need;python3 "$M" diagnose "$R" "${2:-}" --answer "${3:-}";;verify-cases)all;;inject-unknown)need;printf x>"$R/unexpected.entry";;clear-unknown)rm -f -- "$R/unexpected.entry";need;;cleanup)cleanup;;*)exit 2;;esac
