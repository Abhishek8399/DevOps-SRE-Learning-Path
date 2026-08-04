#!/usr/bin/env bash
set -Eeuo pipefail
D="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"&&pwd -P)";L="$D/lab.sh";$L doctor;$L setup;$L verify-cases;if $L diagnose-as mutable-artifact user >/dev/null 2>&1;then exit 1;fi;$L inject-unknown;if $L list >/dev/null 2>&1;then exit 1;fi;$L clear-unknown;$L cleanup;printf 'verification=pass boundary=model-only state_absent=true\n'
